(* open Containers *)

type t = {
  title : string;
  category : string;
  (* the possible original source path of the issue. this may not be
     set if the issue is created new, but it exists so that files that
      are created with "invalid" filepaths are still able to be used/updated.
     
     If we try and create a path based on title and category only, while
     ignoring the original filepath we have a problem where issues can be
     loaded but not read, since the generated file path is different than the
     actual file path. *)
  path : Path.t option;
}

let slug_title title =
  let safe_title = 
    title
    |> String.trim
    |> Str.global_replace (Str.regexp "[^A-Za-z0-9.-]") "_"
  in
  safe_title ^ ".md"

let from_path ~root path =
  let category = 
    path
    |> Path.parent 
    |> Path.to_relative ~root 
    |> Path.parts
    |> String.concat "/"
  in 
  Option.map (fun title -> { title; category; path = Some path })
    (Fs.single_line_of_file path)

let all_issues root =
  Fs.traverse_directory root
  |> List.filter (Path.has_extension ~ext:"md")
  |> List.filter_map (from_path ~root)

let path issue =
  match issue.path with
  | Some x -> x
  | None ->
      Path.(
        append 
          (of_string issue.category)
          (slug_title issue.title)
      )

let title t = t.title
let category t = t.category

let issue_link title relative_path =
  Printf.sprintf "<a class='issue-bookmark' id='%s' href='#%s'>🔖 %s</a>" title title
    (Path.to_string relative_path)

let wrap_in_article issue_html = "<article>" ^ issue_html ^ "</article>"

let replace_text_with_links text =
  text
  (* hashtags *)
  |> Str.global_replace
       (Str.regexp "[ \n\t]\\([A-Za-z0-9-]+\\)#")
       "<a class=\"issue-hash\" title=\"Search hashtag \\1\" \
        href=\"#\">\\1#</a>"
  (* mentions *)
  |> Str.global_replace
       (Str.regexp "[ \n\t]@\\([A-Za-z0-9-]+\\)")
       "<a class=\"issue-mention\" title=\"Search metnion \\1\" \
        href=\"#\">@\\1</a>"
  (* directories *)
  |> Str.global_replace
       (Str.regexp "[ \n\t]\\(/[A-Za-z0-9-]+\\)")
       "<a class=\"issue-directory\" title=\"Search directory \\1\" \
        href=\"#\">\\1</a>"

let markdown_to_html text = 
  text
  |> Omd.of_string 
  |> Omd.to_html

let to_html issue ~root =
  let path = path issue in
  (* read the source markdown file and replace all text with relevant links. *)
  let markdown = replace_text_with_links (Fs.read_entire_file path) in
  (* then turn it into html *)
  let html = markdown_to_html markdown in
  (* generate a link to the current issue *)
  let issue_link = issue_link issue.title (Path.to_relative ~root path) in
  wrap_in_article (issue_link ^ html)
