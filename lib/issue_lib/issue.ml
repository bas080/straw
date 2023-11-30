open Base
module Filename = Stdlib.Filename
module Sys = Stdlib.Sys

type t = {
  title : string;
  category : string;
}

let title_to_filename title =
  title |> String.strip |> Fs.safe_filename

let from_path path =
  let category = Filename.dirname path in 
  In_channel.with_open_text path In_channel.input_line
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
    ((title_to_filename issue.title) ^ ".md")

let title t = t.title
let category t = t.title
