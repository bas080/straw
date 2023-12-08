(* Extensions to Omd, the markdown parser *)

open Omd

module Block : sig
    (** map over the inline elements in a block. *)
    val map :
        f:('a inline -> 'a inline)
        -> 'a block
        -> 'a block

    (** iterate over the inline elements of a block. *)
    val iter :
        f:('a inline -> unit)
        -> 'a  block
        -> unit

    val find :
        f:('a inline -> bool)
        -> 'a block
        -> 'a inline option

    (* val find_map :
        f:('a inline -> 'b option)
        -> 'a block
        -> 'b option *)
end

module Document : sig
    (** map over each block in a document *)
    val map : f:(attributes block -> attributes block) -> doc -> doc

    (** iterate over each block in a document *)
    val iter: f:(attributes block -> unit) -> doc -> unit

    (** attempt to find an element that matches the given predicate *)
    val find :
        f:(attributes block -> bool)
        -> doc
        -> attributes block option

    (* val find_map :
        f:(attributes block -> 'b option)
        -> doc
        -> 'b option *)
end

(** Same as Document.map ~f:(Block.map ~f), but also handles Concat types. *)
val inline_map :
    f:(attributes inline -> attributes inline)
    -> doc
    -> doc

(** Same as Document.iter ~f:(Block.iter ~f), but also handles Concat types. *)
val inline_iter :
    f:(attributes inline -> unit)
    -> doc
    -> unit

val inline_find :
    f:(attributes inline -> bool)
    -> doc
    -> attributes inline option

(* FIXME: type signatures are completely borked *)
(* val inline_find_map :
    f:('a inline -> 'b option)
    -> doc
    -> 'b option *)
