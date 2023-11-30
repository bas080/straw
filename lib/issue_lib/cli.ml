let issue_filename_str str =
  let filename = str |> String.trim |> Fs.safe_filename in
  filename ^ ".md"

(* FIXME: what if we don't find it? *)
let rec find_parent_directory_with_file target_file start_dir =
  let target_file = Filename.concat start_dir target_file in
  if Sys.is_directory target_file then start_dir
  else
    (* Move one dir up and try again *)
    Filename.dirname start_dir |> find_parent_directory_with_file target_file

let parent_dir () =
  let start = Sys.getcwd () (* TODO: make env variable with default *) in
  let target = "issue" in
  Path.of_string (find_parent_directory_with_file target start)

let issue_dir () =
  let dir = parent_dir () in
  Path.concat dir (Path.of_string "issue")

let wrap_in_article issue_html = "<article>" ^ issue_html ^ "</article>"

let wrap_issue_link title relative_path =
  Printf.sprintf "<a class='issue-bookmark' id='%s' href='#%s'>🔖 %s</a>" title title
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

let file_to_html file = Fs.read_entire_file file |> Omd.of_string |> Omd.to_html

(* let to_html root =
   traverse_directory root
   |> List.map ~f:(fun x -> x |> file_to_html |> wrap_in_article)
   |> String.concat ~sep:"\n\n\n" *)

let list () =
  let root = issue_dir () in
  Fs.(traverse_directory root |> List.filter is_md_file)
  |> List.iter (fun path -> print_endline (Path.to_string path))

let move ~src ~dest = Sys.rename src dest

let open_file_with_editor path =
  let editor = Sys.getenv "EDITOR" in
  (* open the temporary file with the default editor *)
  Printf.sprintf "%s %s" editor (Path.to_quoted path) |> Sys.command |> ignore

let find_unique_filename path =
  (* literal copy of what was in perl, not the best for OCaml *)
  let r = Str.regexp "\\.md" in
  let counter = ref 1 in
  let search = ref path in
  while Sys.file_exists !search do
    Printf.eprintf "Possible duplicate issue found:\t%s\n" !search;
    let replacement = Printf.sprintf "_%i.md" !counter in
    search := Str.replace_first r replacement path;
    counter := !counter + 1
  done;
  !search

let open_issue () =
  (* will create the file *)
  let tmpfile = Path.temp_file ~dir:(issue_dir ()) "tmp-" ".md" in
  let open_dir = Path.of_parts ["issue"; "open"] in
  (* create the issue/open directory if it doesn't exit *)
  ignore (Fs.mkdir_p open_dir);
  open_file_with_editor tmpfile;
  let lines = Fs.lines_of_file tmpfile in
  (* extract the title from the contents (first line) *)
  (* TODO: add same regex check as in perl *)
  match List.nth_opt lines 0 with
  | Some title ->
      let issue_file = issue_filename_str title in
      let path = Path.concat open_dir (Path.of_string issue_file) in
      (* check for filename conflicts and find a unique filename *)
      let unique_path = find_unique_filename (Path.to_string path) in
      Printf.printf "Moving %s to %s\n" (Path.to_string tmpfile) unique_path;
      (* TODO: error handling *)
      ignore (move ~src:(Path.to_string tmpfile) ~dest:unique_path);
      Printf.printf "Issue saved at: %s\n" unique_path
  | None ->
      Printf.eprintf "No changes were saved.\n";
      (* cleanup empty tempfile *)
      Sys.remove (Path.to_string tmpfile);
      (* exit with non-standard exit code *)
      exit 1

let edit issue_path =
  let root = issue_dir () in
  let path = Path.concat root (Path.of_string issue_path) in
  if Sys.file_exists (Path.to_string path) 
  then open_file_with_editor path
  else Printf.eprintf "Issue %s does not exist\n" issue_path

let search _root = ()

let categories root =
  root
  |> Fs.ls_dir
  |> List.map (Path.concat root)
  |> List.filter Path.is_directory

let md_files path =
  let open Fs in
  traverse_directory path
  |> List.filter (fun file -> Path.is_file file && is_md_file file)

let status () =
  let root = issue_dir () in
  Fs.ls_dir root
  |> List.map (fun dir ->
         let count = Path.concat root dir |> md_files |> List.length in
         (dir, count))
  |> List.iter (fun (dir, count) -> Printf.printf "%s\t%i\n" (Path.to_string dir) count)

let show _root = ()

let split_on_issues content =
  let r = Str.regexp "<!--issues-->" in
  match Str.bounded_split r content 2 with
  | [ before; after ] -> Some (before, after)
  | _ -> None

let print_html_issues () =
  let root = issue_dir () in
  categories root
  |> List.concat_map md_files
  |> List.map (fun file ->
         let lines = Fs.lines_of_file file in
         let title =
           lines 
           |> (fun l -> List.nth_opt l 0)
           |> Option.value ~default:"Untitled Issue"
           |> issue_filename_str
         in
         let md = file_to_html file in
         wrap_issue_link title (Path.to_string (Path.to_relative ~root file)) ^ md
         |> replace_text_with_links |> wrap_in_article)
  |> List.iter print_endline;
  ()

let html () =
  let template_path = Path.concat (parent_dir ()) (Path.of_string "template.html") in
  let content = Fs.read_entire_file template_path in
  match split_on_issues content with
  | Some (before, after) ->
      print_string before;
      print_html_issues ();
      print_string after
  | None -> Printf.printf "No issues found.\n"

let is_valid_commit_message_from_file file =
  let lines = Fs.lines_of_file file in
  not (List.is_empty lines)

let validate () =
  let root = issue_dir () in
  let exit_code = ref 0 in
  let open Fs in
  traverse_directory root
  |> List.filter (Path.has_extension ~ext:"md")
  |> List.iter (fun file ->
         if is_valid_commit_message_from_file file then
           Printf.printf "valid\t%s\n" (Path.to_string file)
         else (
           Printf.printf "invalid\t%s\n" (Path.to_string file);
           exit_code := 1));
  exit !exit_code
