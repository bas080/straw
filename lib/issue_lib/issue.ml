open Core
module Sys = Sys_unix

type t = {
  title : string;
  category : string;
}

let title_to_filename title =
  let open Fs in
  let filename = title |> String.strip |> safe_filename in
  filename ^ ".md"

let from_path path =
  let category = Filename.dirname path in 
  path
  |> In_channel.with_file ~f:In_channel.input_line
  |> Option.map ~f:(fun raw_title -> 
    let safe_title = title_to_filename raw_title in
    { title = safe_title; category = category })

let all_issues root =
  let open Fs in
  traverse_directory root
  |> List.filter ~f:is_md_file
  |> List.filter_map ~f:from_path

let path issue =
  Filename.concat
    issue.category
    (title_to_filename issue.title)

let title t = t.title
let category t = t.title
