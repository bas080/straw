(* open Containers *)

type t = {
  title : string;
  category : string;
}

let title_to_filename title =
  title |> String.trim |> Fs.safe_filename

let from_path path =
  let category = path |> Path.parent |> Path.to_string in 
  In_channel.with_open_text (Path.to_string path) In_channel.input_line
  |> Option.map (fun raw_title -> 
    let safe_title = title_to_filename raw_title in
    { title = safe_title; category = category })

let all_issues root =
  let open Fs in
  traverse_directory root
  |> List.filter is_md_file
  |> List.filter_map from_path

let path issue =
  Path.of_parts
    [ issue.category; ((title_to_filename issue.title) ^ ".md") ]

let title t = t.title
let category t = t.title
