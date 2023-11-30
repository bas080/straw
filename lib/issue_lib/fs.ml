open Base
module Filename = Stdlib.Filename
module Sys = Stdlib.Sys

let rec traverse_directory path =
  if Sys.is_directory path then
    Sys.readdir path |> Array.to_list
    |> List.concat_map ~f:(fun file ->
           Filename.concat path file |> traverse_directory)
  else [ path ]

let safe_filename filename =
  let r = Str.regexp "[^A-Za-z0-9.-]" in
  Str.global_replace r "_" filename

let has_extension ~extension path =
  String.equal (Filename.extension path) ("." ^ extension)

let is_md_file = has_extension ~extension:"md"

(* Split a path using the OS directory separator. *)
(* TODO: consider using linux-style paths until we need to read/write, possibly
    by writing a Filepath module *)
let path_parts path =
  let r = Str.regexp (Filename.quote Filename.dir_sep) in
  Str.split r path

let absolute_to_relative ~root target=
  let rec find_common_prefix parts1 parts2 = 
    match parts1, parts2 with
    | x :: xs, y :: ys when String.equal x y -> find_common_prefix xs ys
    | _ -> parts1, parts2
  in
  let root_parts = path_parts root in
  let target_parts = path_parts target in
  let remaining_root, remaining_target =
    find_common_prefix root_parts target_parts
  in
  let go_up = List.map ~f:(fun _ -> "..") remaining_root in
  let relative_parts = go_up @ remaining_target in
  String.concat ~sep:Filename.dir_sep relative_parts

let read_entire_file path = In_channel.with_open_text path In_channel.input_all
let lines_of_file path = In_channel.with_open_text path In_channel.input_lines

let rec mkdir_p path =
  if not (Sys.file_exists path) then begin
    let parent = Filename.dirname path in
    if not (String.equal path parent) then begin
      mkdir_p parent
    end
  end;
  Sys.mkdir path 0o777

let ls_dir path = Array.to_list (Sys.readdir path)
