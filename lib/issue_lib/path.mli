type t

val of_string : string -> t
val of_parts : string list -> t
val to_string : t -> string

val concat : t -> t -> t
val parent : t -> t
val parts : t -> string list
val to_relative : root:t -> t -> t
val to_absolute : t -> t

val has_extension : extension:string -> t -> bool
