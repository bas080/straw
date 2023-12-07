(* Extensions to Omd, the markdown parser *)

module Block : sig
    type 'a t = 'a Omd.block
    type 'a inline = 'a Omd.inline

    (** map over the inline elements in a block. *)
    val map : f:('a inline -> 'a inline) -> 'a t -> 'a t

    (** iterate over the inline elements of a block. *)
    val iter : f:('a inline -> unit) -> 'a t -> unit
end

module Document : sig
    type t = Omd.doc
    type attr = Omd.attributes

    (** map over each block in a document *)
    val map : f:(attr Block.t -> attr Block.t) -> t -> t

    (** iterate over each block in a document *)
    val iter: f:(attr Block.t -> unit) -> t -> unit
end

(** Same as Document.map ~f:(Block.map ~f), but also handles Omd.Concat types. *)
val inline_map : f:(Document.attr Block.inline -> Document.attr Block.inline) -> Document.t -> Document.t

(** Same as Document.iter ~f:(Block.iter ~f), but also handles Omd.Concat types. *)
val inline_iter : f:(Document.attr Block.inline -> unit) -> Document.t -> unit
