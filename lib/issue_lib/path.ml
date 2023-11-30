(* we will treat all filepaths as unix and convert them to/from that
   representation to the OS-native representation during of_string or
   to_string. *)

type t = string

let of_string x = 
  if Sys.win32 then
    Str.global_replace (Str.regexp "\\") "/" x
  else
    x

let to_string x = 
  if Sys.win32 then
    Str.global_replace 
      (Str.regexp "/") 
      Filename.dir_sep x
  else
    x

let to_quoted = Filename.quote
let concat = Filename.concat

let of_parts parts = 
  List.fold_left Filename.concat "" parts

let temp_file ?dir prefix suffix =
  of_string (Filename.temp_file ?temp_dir:dir prefix suffix)

let parent path = Filename.dirname path
let parts path = String.split_on_char '/' path

let to_relative ~root path =
  let rec find_common_prefix parts1 parts2 = 
    match parts1, parts2 with
    | x :: xs, y :: ys when String.equal x y -> find_common_prefix xs ys
    | _ -> parts1, parts2
  in
  let root_parts = parts root in
  let target_parts = parts path in
  let remaining_root, remaining_target =
    find_common_prefix root_parts target_parts
  in
  let go_up = List.map (fun _ -> "..") remaining_root in
  let relative_parts = go_up @ remaining_target in
  String.concat Filename.dir_sep relative_parts

let to_absolute path =
  concat (Stdlib.Sys.getcwd ()) path

let extension path = 
  let ext = Filename.extension (to_string path) in
  if String.length ext > 0
  then Some ext
  else None

let has_extension ~ext path =
  match extension path with
  | Some x -> String.equal x ("." ^ ext)
  | None -> false

let is_directory path = Sys.is_directory (to_string path)
let is_file path = Sys.is_regular_file (to_string path)
let exists path = Sys.file_exists (to_string path)

let equal = String.equal
let compare = String.compare
