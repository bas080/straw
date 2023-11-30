(* open Containers *)

type t = {
  title : string;
  category : string;
}

let title_to_filename title =
  title
  |> String.trim
  |> Str.global_replace (Str.regexp "[^A-Za-z0-9.-]") "_"

(* FIXME: wont work if passed an absolute path since the category 
    will contain the entire parent path of the current file. Try and come
  up with a better way of handling this, e.g. the name of the top-most folder *)
let from_path path =
  let category = path |> Path.parent |> Path.to_string in 
  In_channel.with_open_text (Path.to_string path) In_channel.input_line
  |> Option.map (fun title -> { title; category })

let all_issues root =
  Fs.traverse_directory root
  |> List.filter (Path.has_extension ~ext:"md")
  |> List.filter_map from_path

let path issue =
  Path.(
    append 
      (of_string issue.category)
      ((title_to_filename issue.title) ^ ".md")
  )

let title t = t.title
let category t = t.category
