(* Extensions to Omd, the markdown parser *)

open Omd

module Block : sig
    (** map over the inline elements in a block. *)
    val map :
        f:('a inline -> 'a inline)
        -> ?concat:bool
        -> 'a block
        -> 'a block

    (** iterate over the inline elements of a block. *)
    val iter :
        f:('a inline -> unit)
        -> ?concat:bool
        -> 'a  block
        -> unit

    val find :
        f:('a inline -> bool)
        -> ?concat:bool
        -> 'a block
        -> 'a inline option

    val find_map :
        f:('a inline -> 'b option)
        -> ?concat:bool
        -> 'a block
        -> 'b option
end

module Document : sig
    (** map over each block in a document *)
    val map : f:('a block -> 'a block) -> 'a block list -> 'a block list

    (** iterate over each block in a document *)
    val iter: f:('a block -> unit) -> 'a block list -> unit

    (** attempt to find an element that matches the given predicate *)
    val find :
        f:('a block -> bool)
        -> 'a block list
        -> 'a block option

    val find_map :
        f:('a block -> 'b option)
        -> 'a block list
        -> 'b option
end

(** Same as Document.map ~f:(Block.map ~f) *)
val inline_map :
    f:('a inline -> 'a inline)
    -> ?concat:bool
    -> 'a block list
    -> 'a block list

(** Same as Document.iter ~f:(Block.iter ~f) *)
val inline_iter :
    f:('a inline -> unit)
    -> ?concat:bool
    -> 'a block list
    -> unit

val inline_find :
    f:('a inline -> bool)
    -> ?concat:bool
    -> 'a block list
    -> 'a inline option

val inline_find_map :
    f:('a inline -> 'b option)
    -> ?concat:bool
    -> 'a block list
    -> 'b option
