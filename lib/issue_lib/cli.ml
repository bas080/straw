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

let slug_title title =
  let safe_title =
    title
    |> String.trim
    |> String.lowercase_ascii
    |> Str.global_replace (Str.regexp "[^A-Za-z0-9.-]") "_"
  in
  safe_title ^ ".md"

(* extract the title from the contents (first line) *)
let title path =
  path
  |> File_util.read_entire_file
  |> Omd.of_string
  |> Omd_util.title_of_doc

let category ~root path =
  path
  |> Path.to_relative ~root
  |> Path.parent
  |> Path.parts
  |> String.concat "/"

let path_of_title ~root category title =
  Path.(
    concat
      root
      (append
        (of_string category)
        (slug_title title)))

let all_issues root =
  File_util.traverse_directory root
  |> List.filter (Path.has_extension ~ext:"md")

let issue_link title relative_path =
  Printf.sprintf "<a class='issue-bookmark' id='%s' href='#%s'>🔖 %s</a>" title title
    (Path.to_string relative_path)

let wrap_in_article issue_html = "<article>" ^ issue_html ^ "</article>"

let md_to_html ~root path =
  let doc = Omd.of_string (File_util.read_entire_file path) in
  let doc = Omd_util.replace_text_with_links doc in
  let html = Omd.to_html doc in
  let issue_link =
    issue_link
      (Option.value ~default: "Unknown document" (title path))
      (Path.to_relative ~root path)
  in
  wrap_in_article (issue_link ^ html)

let open_file_with_editor path =
  let getenv name default = Option.value ~default (Sys.getenv_opt name) in
  let editor = getenv "EDITOR" "vi" in
  (* open the temporary file with the default editor *)
  Printf.sprintf "%s %s" editor (Path.to_quoted path)
  |> Sys.command
  |> ignore

(* the functional implementation of this is much more obtuse *)
let find_unique_filename path =
  let path = Path.to_string path in
  let r = Str.regexp {|\.md|} in
  let counter = ref 1 in
  let search = ref path in
  while Sys.file_exists !search do
    Printf.printf "Possible duplicate issue found:\t%s\n" !search;
    let replacement = Printf.sprintf "_%i.md" !counter in
    search := Str.replace_first r replacement path;
    counter := !counter + 1
  done;
  Path.of_string !search

let list () =
  let root = issue_dir () in
  all_issues root
  |> List.iter (fun path ->
    Path.(
      path
      |> to_relative ~root
      |> to_string
      |> print_endline))

let open_issue () =
  let root = issue_dir () in
  (* will create the file *)
  let tmpfile = Path.temp_file ~dir:root "tmp-" ".md" in
  let open_dir = Path.of_string "issue/open" in
  (* create the issue/open directory if it doesn't exit *)
  ignore (File_util.mkdir_p open_dir);
  open_file_with_editor tmpfile;
  match title tmpfile with
  | Some title ->
    let path = path_of_title ~root "open" title |> find_unique_filename in
    Printf.printf "Moving %s to %s\n"
      (Path.to_string tmpfile) (Path.to_string path);
    (* TODO: error handling *)
    ignore (File_util.move ~src:tmpfile ~dest:path);
    Printf.printf "Issue saved at: %s\n" (Path.to_string path)
  | None ->
    Printf.eprintf "No changes were saved.\n";
    (* cleanup empty tempfile *)
    Sys.remove (Path.to_string tmpfile);
    (* exit with non-standard exit code *)
    exit 1

let search _root = ()

let status () =
  let root = issue_dir () in
  all_issues root
  |> List.to_seq
  (* group by category *)
  |> Seq.group (fun a b ->
      String.equal
        (category ~root a)
        (category ~root b))
  (* get a count for each category *)
  |> Seq.map (fun s ->
      let category = s |> List.of_seq |> List.hd |> category ~root in
      (category, Seq.length s))
  |> Seq.filter(fun (c, _) ->
      (* filter . files *)
      not (String.equal c Filename.current_dir_name))
  |> Seq.iter (fun (category, count) ->
      Printf.printf "%s\t%i\n" category count)

let split_on_issues content =
  let r = Str.regexp "<!--issues-->" in
  match Str.bounded_split r content 2 with
  | [ before; after ] -> Some (before, after)
  | _ -> None

let print_html_issues () =
  let root = issue_dir () in
  all_issues root
  |> List.map (md_to_html ~root)
  |> List.iter print_endline;
  ()

let html () =
  let template_path = Path.append (issue_dir ()) "template.html" in
  let template =
    (* if the template path doesn't exist, create it with the bundled
       template.html *)
    if not (Path.exists template_path) then begin
      File_util.write_entire_file template_path Template.html
    end;
    File_util.read_entire_file template_path
  in
  match split_on_issues template with
  | Some (before, after) ->
      print_string before;
      print_html_issues ();
      print_string after
  | None -> Printf.eprintf "Invalid template.html, does not contain <!--issues-->.\n"
