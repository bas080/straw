(* Return a directory that contains the given [target_file], or [None]
   if no file was found *)
let rec find_parent_directory_with_file target_file start_dir =
  let path = Path.concat start_dir target_file in
  if Path.exists path then 
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
      Printf.sprintf "issue directory could not be found. use '%s open' to create issues."
        Sys.executable_name)

let issue_dir () = Path.append (project_dir ()) "issue"

let list () =
  let root = issue_dir () in
  Issue.all_issues root
  |> List.iter (fun issue -> 
    Path.(
      Issue.path issue
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

let find_unique_filename (path : Path.t) =
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

let open_issue () =
  (* will create the file *)
  let root = issue_dir () in
  let tmpfile = Path.temp_file ~dir:root "tmp-" ".md" in
  let open_dir = Path.of_string "issue/open" in
  (* create the issue/open directory if it doesn't exit *)
  ignore (Fs.mkdir_p open_dir);
  open_file_with_editor tmpfile;
  (* extract the title from the contents (first line) *)
    (* TODO: read a few lines if the first one isn't used *)
    (* TODO: add same regex check as in perl, skip whitespace *)
  match Fs.single_line_of_file tmpfile with 
  | Some title when not (String.equal title String.empty) ->
    let issue = Issue.from_title ~root "open" title in
    let path = Path.concat open_dir (Issue.path issue) in
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
  Issue.all_issues root
  |> List.to_seq
  (* group by category *)
  |> Seq.group (fun a b -> 
      String.equal 
        (Issue.category a)
        (Issue.category b))
  (* get a count for each category *)
  |> Seq.map (fun s -> 
      let category = s |> List.of_seq |> List.hd |> Issue.category in
      (category, Seq.length s))
  |> Seq.iter (fun (category, count) ->
      Printf.printf "%s\t%i\n" category count)

let show _root = ()

let split_on_issues content =
  let r = Str.regexp "<!--issues-->" in
  match Str.bounded_split r content 2 with
  | [ before; after ] -> Some (before, after)
  | _ -> None

let print_html_issues () =
  let root = issue_dir () in
  Issue.all_issues root
  |> List.map Issue.to_html
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
  | None -> Printf.eprintf "Invalid template.html, does not contain <!--issues-->.\n"
