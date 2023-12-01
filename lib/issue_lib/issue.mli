type t

(** List of all issues contained inside of the given [root] directory *)
val all_issues : Path.t -> t list

(** Create a new issue given a path *)
val from_path : root:Path.t -> Path.t -> t option

(** Return the file path where the issue is stored. *)
val path : t -> Path.t

val title : t -> string
val category : t -> string

val to_html : t -> root:Path.t -> string
