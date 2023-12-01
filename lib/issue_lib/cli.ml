let issue_filename_str str =
  let filename = str |> String.trim |> Fs.safe_filename in
  filename ^ ".md"

(* Return a directory that contains the given [target_file], or [None]
   if no file was found *)
let rec find_parent_directory_with_file target_file start_dir =
  let target_file = Path.concat start_dir target_file in
  if Path.exists target_file then 
    Some start_dir
  else if Path.is_root start_dir then
    (* doesn't exist *)
    None
  else
    let parent = Path.parent start_dir in
    (* Move one dir up and try again *)
    find_parent_directory_with_file target_file parent

(* Returns the parent of the issue directory, considered the project root. *)
let project_dir () =
  let start = Path.of_string (Sys.getcwd ()) in
  let target = Path.of_string "issue" in
  match find_parent_directory_with_file target start with
  | Some x -> x
  | None ->
    failwith (
      Printf.sprintf "issue directory could not be found. use %s open to create issues."
        Sys.executable_name)

let issue_dir () = Path.append (project_dir ()) "issue"

let md_files path =
  Fs.traverse_directory path
  |> List.filter (fun path -> 
      Path.is_file path && Path.has_extension ~ext:"md" path)

let list () =
  let root = issue_dir () in
  md_files root
  |> List.iter (fun path -> 
    Path.(
      path
      |> to_relative ~root
      |> to_string
      |> print_endline))

let open_file_with_editor path =
  let getenv name default = Option.value ~default (Sys.getenv_opt name) in
  let editor = getenv "EDITOR" "vi" in
  (* open the temporary file with the default editor *)
  Printf.sprintf "%s %s" editor (Path.to_quoted path) 
  |> Sys.command 
  |> ignore

let find_unique_filename path =
  (* literal copy of what was in perl, not the best for OCaml *)
  let r = Str.regexp "\\.md" in
  let counter = ref 1 in
  let path = Path.to_string path in
  let search = ref path in
  while Sys.file_exists !search do
    Printf.eprintf "Possible duplicate issue found:\t%s\n" !search;
    let replacement = Printf.sprintf "_%i.md" !counter in
    search := Str.replace_first r replacement path;
    counter := !counter + 1
  done;
  Path.of_string !search

let open_issue () =
  (* will create the file *)
  let tmpfile = Path.temp_file ~dir:(issue_dir ()) "tmp-" ".md" in
  let open_dir = Path.of_string "issue/open" in
  (* create the issue/open directory if it doesn't exit *)
  ignore (Fs.mkdir_p open_dir);
  open_file_with_editor tmpfile;
  (* extract the title from the contents (first line) *)
    (* TODO: read a few lines if the first one isn't used *)
    (* TODO: add same regex check as in perl, skip whitespace *)
  match Fs.single_line_of_file tmpfile with 
  | Some title when not (String.equal title String.empty) ->
      let issue_path = issue_filename_str title in
      let path = Path.append open_dir issue_path in
      (* check for filename conflicts and find a unique filename *)
      let unique_path = find_unique_filename path in
      Printf.printf "Moving %s to %s\n" 
        (Path.to_string tmpfile) (Path.to_string unique_path);
      (* TODO: error handling *)
      ignore (Fs.move ~src:tmpfile ~dest:unique_path);
      Printf.printf "Issue saved at: %s\n" (Path.to_string unique_path)
  | Some _ | None -> 
    Printf.eprintf "No changes were saved.\n";
    (* cleanup empty tempfile *)
    Sys.remove (Path.to_string tmpfile);
    (* exit with non-standard exit code *)
    exit 1

let edit issue_path =
  let root = issue_dir () in
  let path = Path.append root issue_path in
  if Path.exists path
  then open_file_with_editor path
  else Printf.eprintf "Issue %s does not exist.\n" issue_path

let search _root = ()

let status () =
  let root = issue_dir () in
  Fs.ls_dir root
  |> List.filter Path.is_directory
  |> List.map (fun dir ->
      let count = List.length (md_files dir) in
      (dir, count))
  |> List.iter (fun (dir, count) -> 
      let relpath = Path.(to_string (to_relative ~root dir)) in
      Printf.printf "%s\t%i\n" relpath count)

let show _root = ()

let split_on_issues content =
  let r = Str.regexp "<!--issues-->" in
  match Str.bounded_split r content 2 with
  | [ before; after ] -> Some (before, after)
  | _ -> None

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

let html_issues root path =
  let lines = Fs.lines_of_file path in
  let title =
    lines 
    |> (fun l -> List.nth_opt l 0)
    |> Option.value ~default:"Untitled Issue"
    |> issue_filename_str
  in
  (* read the source markdown file and replace all text with relevant links. *)
  let markdown = replace_text_with_links (Fs.read_entire_file path) in
  (* then turn it into html *)
  let html = markdown_to_html markdown in
  (* generate a link to the current issue *)
  let issue_link = issue_link title (Path.to_relative ~root path) in
  wrap_in_article (issue_link ^ html)

let print_html_issues () =
  let root = issue_dir () in
  md_files root
  |> List.map (html_issues root)
  |> List.iter print_endline;
  ()

let html () =
  let template_path = Path.append (project_dir ()) "template.html" in
  let content = Fs.read_entire_file template_path in
  match split_on_issues content with
  | Some (before, after) ->
      print_string before;
      print_html_issues ();
      print_string after
  | None -> Printf.printf "Invalid template.html, does not contain <!--issues-->.\n"
