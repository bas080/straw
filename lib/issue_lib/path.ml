(* 
  we will treat all filepaths as unix and convert them to/from that
  representation to the OS-native representation during of_string or
  to_string. 
*)

type t = Fpath.t

let is_root path = 
  Fpath.is_root (Fpath.normalize path)

(* for now we'll assume that strings are trusted, TODO: use Fpath.of_string *)
let of_string = Fpath.v
let to_string = Fpath.to_string

(* FIXME: figure out how to do this in fpath *)
let to_quoted path = Filename.quote (to_string path)
let append = Fpath.add_seg
let concat = Fpath.append

let temp_file ?dir prefix suffix =
  let temp_dir = Option.map to_string dir in
  of_string (Filename.temp_file ?temp_dir prefix suffix)

let parent = Fpath.parent
let parts = Fpath.segs

let to_relative ~root path = 
  (* for now we'll assume its always fine *)
  Option.get (Fpath.relativize ~root path)

let to_absolute path =
  concat (of_string (Sys.getcwd ())) path

let extension path =
  let ext = Fpath.get_ext path in
  if String.length ext > 0
  then Some ext
  else None

let has_extension ~ext path = Fpath.has_ext ext path

let is_directory path = 
  Fpath.is_dir_path path || Sys.is_directory (to_string path)

let is_file path = 
  Fpath.is_file_path path || Sys.is_regular_file (to_string path)

let exists path = Sys.file_exists (to_string path)

let equal = Fpath.equal
let compare = Fpath.compare
