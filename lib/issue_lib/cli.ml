open Core
module Unix = Core_unix
module Sys = Sys_unix

let issue_filename_str str =
  let filename = str |> String.strip |> Fs.safe_filename in
  filename ^ ".md"

(* FIXME: what if we don't find it? *)
let rec find_parent_directory_with_file target_file start_dir =
  let target_file = Filename.concat start_dir target_file in
  if Sys.is_directory_exn target_file then start_dir
  else
    (* Move one dir up and try again *)
    Filename.dirname start_dir |> find_parent_directory_with_file target_file

let parent_dir () =
  let start = Unix.getcwd () (* TODO: make env variable with default *) in
  let target = "issue" in
  find_parent_directory_with_file target start

let issue_dir () =
  let dir = parent_dir () in
  Filename.concat dir "issue"

let absolute_to_relative root target =
  Filename.of_absolute_exn target ~relative_to:root

let wrap_in_article issue_html = "<article>" ^ issue_html ^ "</article>"

let wrap_issue_link title relative_path =
  sprintf "<a class='issue-bookmark' id='%s' href='#%s'>🔖 %s</a>" title title
    relative_path

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

let read_entire_file path = In_channel.with_file path ~f:In_channel.input_all
let lines_of_file path = In_channel.with_file path ~f:In_channel.input_lines
let file_to_html file = read_entire_file file |> Omd.of_string |> Omd.to_html

(* let to_html root =
   traverse_directory root
   |> List.map ~f:(fun x -> x |> file_to_html |> wrap_in_article)
   |> String.concat ~sep:"\n\n\n" *)

let list root =
  Issue.all_issues root
  |> List.iter ~f:(fun issue -> print_endline (Issue.path issue))

let move from to' = Unix.rename ~src:from ~dst:to'

let open_file_with_editor path =
  let editor = Core.Sys.getenv "EDITOR" |> Option.value ~default:"vi" in
  (* open the temporary file with the default editor *)
  sprintf "%s %s" editor (Filename.quote path) |> Sys.command |> ignore

let find_unique_filename path =
  (* literal copy of what was in perl, not the best for OCaml *)
  let r = Str.regexp "\\.md" in
  let counter = ref 1 in
  let search = ref path in
  while Sys.file_exists_exn !search do
    eprintf "Possible duplicate issue found:\t%s\n" !search;
    let replacement = sprintf "_%i.md" !counter in
    search := Str.replace_first r replacement path;
    counter := !counter + 1
  done;
  !search

let open_issue () =
  (* will create the file *)
  let tmpfile = Filename_unix.temp_file ~in_dir:"issue" "tmp-" ".md" in
  let open_dir = Filename.concat "issue" "open" in
  (* create the issue/open directory if it doesn't exit *)
  ignore (Unix.mkdir_p open_dir);
  open_file_with_editor tmpfile;
  let lines = lines_of_file tmpfile in
  (* extract the title from the contents (first line) *)
  (* TODO: add same regex check as in perl *)
  match List.hd lines with
  | Some title ->
      let issue_file = issue_filename_str title in
      let path = Filename.concat open_dir issue_file in
      (* check for filename conflicts and find a unique filename *)
      let unique_path = find_unique_filename path in
      printf "Moving %s to %s.\n" tmpfile unique_path;
      (* TODO: error handling *)
      ignore (move tmpfile unique_path);
      printf "Issue saved at: %s\n" unique_path
  | None ->
      eprintf "No changes were saved.\n";
      (* cleanup empty tempfile *)
      Sys.remove tmpfile;
      (* exit with non-standard exit code *)
      exit 1

let edit issue_path =
  let root = issue_dir () in
  let path = Filename.concat root issue_path in
  if Sys.file_exists_exn path then
    open_file_with_editor path
  else eprintf "Issue %s does not exist\n" issue_path

let search _root = ()

let categories root =
  Issue.all_issues root
  |> List.map ~f:Issue.category

let md_files path =
  let open Fs in
  traverse_directory path
  |> List.filter ~f:(fun file -> Sys.is_file_exn file && is_md_file file)

let status () =
  let root = issue_dir () in
  Sys.ls_dir root
  |> List.map ~f:(fun dir ->
         let count = Filename.concat root dir |> md_files |> List.length in
         (dir, count))
  |> List.iter ~f:(fun (dir, count) -> printf "%s\t%i\n" dir count)

let show _root = ()

let split_on_issues content =
  let r = Str.regexp "<!--issues-->" in
  match Str.bounded_split r content 2 with
  | [ before; after ] -> Some (before, after)
  | _ -> None

let print_html_issues () =
  let root = issue_dir () in
  categories root
  |> List.concat_map ~f:md_files
  |> List.map ~f:(fun file ->
         let lines = lines_of_file file in
         let title =
           lines |> List.hd
           |> Option.value ~default:"Untitled Issue"
           |> issue_filename_str
         in
         let md = file_to_html file in
         wrap_issue_link title (absolute_to_relative root file) ^ md
         |> replace_text_with_links |> wrap_in_article)
  (* TODO: get relative path *)
  |> List.iter ~f:print_endline;
  ()

let html () =
  let template_path = Filename.concat (parent_dir ()) "template.html" in
  let content = read_entire_file template_path in
  match split_on_issues content with
  | Some (before, after) ->
      print_string before;
      print_html_issues ();
      print_string after
  | None -> eprintf "No issues found.\n"

let is_valid_commit_message_from_file file =
  let lines = lines_of_file file in
  Option.is_some (List.hd lines)

let validate () =
  let root = issue_dir () in
  let exit_code = ref 0 in
  let open Fs in
  traverse_directory root |> List.filter ~f:is_md_file
  |> List.iter ~f:(fun file ->
         if is_valid_commit_message_from_file file then
           printf "valid\t%s\n" file
         else (
           printf "invalid\t%s\n" file;
           exit_code := 1));
  exit !exit_code
