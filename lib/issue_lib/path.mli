type t

(** The root directory. *)
val root : t

(** Create a [Path.t] from a string. *)
val of_string : string -> t

(** Create a [Path.t] using the parts of a path.
    {[
    Path.of_parts ["home"; "rage"; "test.md"] 
    ]} 
*)
val of_parts : string list -> t

(** Return a new [Path.t] containing the location of a temporary file. *)
val temp_file : ?dir:t -> string -> string -> t

(** Convert the path to a string. *)
val to_string : t -> string

(** Converts the path to an escaped file path. Same as [Filename.quote]. *)
val to_quoted : t -> string

(** Append a string to the end of a path. *)
val append : t -> string -> t

(** Concatinate two paths together, similar to Filename.concat. *)
val concat : t -> t -> t

(** Return a path representing the parent directory. *)
val parent : t -> t

(** Split a path into its individual parts. *)
val parts : t -> string list

(** Convert the path to be relative to the given root path. *)
val to_relative : root:t -> t -> t

(** Convert the path to be absolute. It uses the value of getcwd as 
    the base path. *)
val to_absolute : t -> t

(** Returns the extension of the file (without the .), if any exists. *)
val extension : t -> string option

(** Returns true if the path has an extension that matches
    the [ext] parameter.
    
    {[
        Path.of_string "test.md" |> Path.has_extension ~ext:"md"
    ]}
*)
val has_extension : ext:string -> t -> bool

(** Returns true if the current path points to a directory. *)
val is_directory : t -> bool

(** Returns true if the current path points to a file. *)
val is_file : t -> bool

(** Returns true if the path exists on the file system. *)
val exists: t -> bool

(** Returns true if the 2 paths are exactly equal. *)
val equal : t -> t -> bool

(** Comparator for paths. -1 if less than, 0 if equal, 1 if greater than. *)
val compare : t -> t -> int
