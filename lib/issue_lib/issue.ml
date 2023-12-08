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

let title_from_md doc =
  doc
  |> Omd_ext.inline_find_map
      ~f:(function Omd.Text (_, s) -> Some s | _ -> None)
  |> Option.value ~default:"Untitled document"

let title issue =
  path issue
  |> File_util.read_entire_file
  |> Omd.of_string
  |> title_from_md

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

(* split a string, extracting a list of Omd.Link and Omd.Text *)
let split_links attr (tag, r) text =
  Str.full_split r text
  |> List.map (function
    | Str.Delim (s) ->
      let label = Omd.Text (attr, s) in
      let title = Some ("Search " ^ tag ^ " " ^ s) in
      Omd.Link (
        [("class", "issue-" ^ tag)],
        { Omd.title; label; destination = "#" })
    | Str.Text (s) -> Omd.Text (attr, s))

let mention_regexp = Str.regexp {|@\([A-Za-z0-9]+\)|}
let hashtag_regexp = Str.regexp {|#\([A-Za-z0-9]+\)|}

let extract_links attr text =
  split_links attr ("mention", mention_regexp) text
  |> List.concat_map (
    function
    | Omd.Text (attr, s) -> split_links attr ("hashtag", hashtag_regexp) s
    | _ as x -> [x])

let replace_text_with_links = Omd_ext.inline_map ~f:(function
  | Omd.Text (attr, s) as t ->
    let links = extract_links attr s in
    if List.is_empty links
    then t
    else Omd.Concat (attr, links)
  | _ as x -> x)

let to_html issue =
  let path = path issue in
  (* read the source markdown file and replace all text with relevant links. *)
  let markdown = Omd.of_string (File_util.read_entire_file path) in
  let markdown = replace_text_with_links markdown in
  (* then turn it into html *)
  let html = Omd.to_html markdown in
  (* generate a link to the current issue *)
  let issue_link = issue_link (title issue)
    (Path.to_relative ~root:issue.root path)
  in
  wrap_in_article (issue_link ^ html)
