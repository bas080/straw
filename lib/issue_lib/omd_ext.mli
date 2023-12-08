(* Extensions to Omd, the markdown parser *)

module Block : sig
    (** map over the inline elements in a block. *)
    val map :
        f:('a Omd.inline -> 'a Omd.inline)
        -> 'a Omd.block
        -> 'a Omd.block

    (** iterate over the inline elements of a block. *)
    val iter :
        f:('a Omd.inline -> unit)
        -> 'a  Omd.block
        -> unit

    val find :
        f:('a Omd.inline -> bool)
        -> 'a Omd.block
        -> 'a Omd.inline option

    (* val find_map :
        f:('a Omd.inline -> 'b option)
        -> 'a Omd.block
        -> 'b option *)
end

module Document : sig
    (** map over each block in a document *)
    val map : f:(Omd.attributes Omd.block -> Omd.attributes Omd.block) -> Omd.doc -> Omd.doc

    (** iterate over each block in a document *)
    val iter: f:(Omd.attributes Omd.block -> unit) -> Omd.doc -> unit

    (** attempt to find an element that matches the given predicate *)
    val find :
        f:(Omd.attributes Omd.block -> bool)
        -> Omd.doc
        -> Omd.attributes Omd.block option

    (* val find_map :
        f:(Omd.attributes Omd.block -> 'b option)
        -> Omd.doc
        -> 'b option *)
end

(** Same as Document.map ~f:(Block.map ~f), but also handles Omd.Concat types. *)
val inline_map :
    f:(Omd.attributes Omd.inline -> Omd.attributes Omd.inline)
    -> Omd.doc
    -> Omd.doc

(** Same as Document.iter ~f:(Block.iter ~f), but also handles Omd.Concat types. *)
val inline_iter :
    f:(Omd.attributes Omd.inline -> unit)
    -> Omd.doc
    -> unit

val inline_find :
    f:(Omd.attributes Omd.inline -> bool)
    -> Omd.doc
    -> Omd.attributes Omd.inline option

(* FIXME: type signatures are completely borked *)
(* val inline_find_map :
    f:('a Omd.inline -> 'b option)
    -> Omd.doc
    -> 'b option *)
