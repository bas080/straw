(* open Containers *)

(* OUTDATED: the possible original source path of the issue. this may not be
    set if the issue is created new, but it exists so that files that
    are created with "invalid" filepaths are still able to be used/updated.

    If we try and create a path based on title and category only, while
    ignoring the original filepath we have a problem where issues can be
    loaded but not read, since the generated file path is different than the
    actual file path. *)
type t = { root : Path.t; path : Path.t }

let find_unique_filename path =
  (* literal copy of what was in perl, not the best for OCaml *)
  let r = Str.regexp "\\.md" in
  let rec count_files search counter =
    if Sys.file_exists search then begin
      Printf.eprintf "Possible duplicate issue found:\t%s\n" search;
      let search =
        Str.replace_first r
          (Printf.sprintf "_%i.md" counter)
          (Path.to_string path)
      in
      count_files search (counter + 1)
    end else search
  in Path.(of_string (count_files (to_string path) 1))

let slug_title title =
  let safe_title =
    title
    |> String.trim
    |> Str.global_replace (Str.regexp "[^A-Za-z0-9.-]") "_"
  in
  safe_title ^ ".md"

let from_path ~root path =
  { root; path = Path.to_relative ~root path }

let path issue =
  Path.concat issue.root issue.path

let from_title ~root category title =
  let path = Path.(
    concat
      root
      (append
        (of_string category)
        (slug_title title))
  ) |> find_unique_filename in
  from_path ~root path

let title issue =
  path issue
  |> File_util.single_line_of_file
  |> Option.value ~default:""

let category issue =
  (* path is already relative*)
  issue.path
  |> Path.parent
  |> Path.parts
  |> String.concat "/"

let all_issues root =
  File_util.traverse_directory root
  |> List.filter (Path.has_extension ~ext:"md")
  |> List.map (from_path ~root)

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

let to_html issue =
  let path = path issue in
  (* read the source markdown file and replace all text with relevant links. *)
  let markdown = replace_text_with_links (File_util.read_entire_file path) in
  (* then turn it into html *)
  let html = markdown_to_html markdown in
  (* generate a link to the current issue *)
  let issue_link = issue_link (title issue)
    (Path.to_relative ~root:issue.root path)
  in
  wrap_in_article (issue_link ^ html)
