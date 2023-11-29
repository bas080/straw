open Core
module Sys = Sys_unix

let rec traverse_directory path =
  if Sys.is_directory_exn path then
    Sys.readdir path |> Array.to_list
    |> List.concat_map ~f:(fun file ->
           Filename.concat path file |> traverse_directory)
  else [ path ]

let safe_filename filename =
  let r = Str.regexp "[^A-Za-z0-9.-]" in
  Str.global_replace r "_" filename

let has_extension ~extension path =
  Filename.split_extension path
  |> snd
  |> Option.for_all ~f:(fun ext -> ext |> String.lowercase |> String.equal extension)

let is_md_file = has_extension ~extension:"md"
