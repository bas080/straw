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

(* Returns the parent of the straw directory, considered the project root. *)
let project_dir () =
  let start = Path.of_string (Sys.getcwd ()) in
  let target = Path.of_string "straw" in
  match find_parent_directory_with_file target start with
  | Some x -> x
  | None ->
    failwith (
      Printf.sprintf "straw directory could not be found, use '%s init' to create one."
        Sys.executable_name)

let straw_dir () = Path.append (project_dir ()) "straw"

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

let all_items root =
  File_util.traverse_directory root
  |> List.filter (Path.has_extension ~ext:"md")

let item_link relative_path =
  let filename = Path.filename relative_path in
  Printf.sprintf "<a class='straw-bookmark' id='%s' href='#%s'>🔖 %s</a>"
    filename
    filename
    (Path.to_string relative_path)

let wrap_in_article item_html = "<article>" ^ item_html ^ "</article>"

let md_to_html ~root path =
  let doc = Omd.of_string (File_util.read_entire_file path) in
  let doc = Omd_util.replace_text_with_links doc in
  let html = Omd.to_html doc in
  let item_link =
    item_link (Path.to_relative ~root path)
  in
  wrap_in_article (item_link ^ html)

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
    Printf.printf "Possible duplicate item found:\t%s\n" !search;
    let replacement = Printf.sprintf "_%i.md" !counter in
    search := Str.replace_first r replacement path;
    counter := !counter + 1
  done;
  Path.of_string !search

let init () =
  (* create the straw dir in whatever directory we're in *)
  let cwd = Path.of_string (Sys.getcwd ()) in
  let straw_dir = Path.append cwd "straw" in
  Printf.printf "Creating straw directory in %s\n"
    (Path.to_string straw_dir);
  File_util.mkdir_p straw_dir

let list () =
  let root = straw_dir () in
  let cwd = Path.of_string (Sys.getcwd ()) in
  all_items root
  |> List.sort Path.compare
  |> List.iter (fun path ->
    Path.(
      path
      |> to_relative ~root:cwd
      |> to_string
      |> print_endline))

let open_item () =
  let root = straw_dir () in
  (* will create the file *)
  let tmpfile = Path.temp_file ~dir:root "tmp-" ".md" in
  let open_dir = Path.of_string "straw/open" in
  (* create the straw/open directory if it doesn't exit *)
  ignore (File_util.mkdir open_dir);
  open_file_with_editor tmpfile;
  match title tmpfile with
  | Some title ->
    let path = path_of_title ~root "open" title |> find_unique_filename in
    Printf.printf "Moving %s to %s.\n"
      (Path.to_string tmpfile) (Path.to_string path);
    (* TODO: error handling *)
    ignore (File_util.move ~src:tmpfile ~dest:path);
    Printf.printf "File saved at %s.\n" (Path.to_string path)
  | None ->
    Printf.eprintf "No changes were saved.\n";
    (* cleanup empty tempfile *)
    Sys.remove (Path.to_string tmpfile);
    (* exit with non-standard exit code *)
    exit 1

let search _root = ()

let status () =
  let root = straw_dir () in
  all_items root
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

let split_on_items content =
  let r = Str.regexp "<!--items-->" in
  match Str.bounded_split r content 2 with
  | [ before; after ] -> Some (before, after)
  | _ -> None

let print_html_items () =
  let root = straw_dir () in
  all_items root
  |> List.map (md_to_html ~root)
  |> List.iter print_endline;
  ()

let html () =
  let template_path = Path.append (straw_dir ()) "template.html" in
  let template =
    (* if the template path doesn't exist, create it with the bundled
       template.html *)
    if not (Path.exists template_path) then begin
      File_util.write_entire_file template_path Template.html
    end;
    File_util.read_entire_file template_path
  in
  match split_on_items template with
  | Some (before, after) ->
      print_string before;
      print_html_items ();
      print_string after
  | None ->
    Printf.eprintf "Invalid template.html, does not contain <!--straws-->.\n";
    exit 1
