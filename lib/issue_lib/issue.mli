type t

(** List of all issues contained inside of the given [root] directory *)
val all_issues : string -> t list

(** Create a new issue given a path *)
val from_path : string -> t option

(** Return the file path where the issue is stored. *)
val path : t -> string

val title : t -> string
val category : t -> string
