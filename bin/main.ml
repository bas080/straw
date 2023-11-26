(* let absolute_path path =
  let cwd = Sys.getcwd ()
  in Filename.concat cwd path *)

let getenv name =
  try
    Some (Sys.getenv name)
  with Not_found -> None

let flat_map (f: 'a -> 'b list) (a : 'a list) : 'b list =
  a
  |> List.map f
  |> List.flatten

let safe_list_hd lst = 
  try
    Some (List.hd lst)
  with Failure _ -> None

let rec find_parent_directory_with_file target_file start_dir =
  let target_file = Filename.concat start_dir target_file
  in
    if Sys.is_directory target_file then
      start_dir
    else
      (* Move one dir up and try again *)
      Filename.dirname start_dir
      |> find_parent_directory_with_file target_file

let parent_dir () =
  let start = Sys.getcwd ()
  (* TODO: make env variable with default *)
  in let target = "issue"
  in find_parent_directory_with_file target start

(* TODO: use path handler *)
let issue_dir () =
  let dir = parent_dir ()
  in Filename.concat dir "issue"

let rec traverse_directory path =
  if Sys.is_directory path then
    Sys.readdir path
    |> Array.to_list
    |> flat_map(fun file ->
        Filename.concat path file
        |> traverse_directory
      )
  else [path]

let wrap_in_article issue_html =
  "<article>" ^ issue_html ^ "</article>"

let read_entire_file path =
  In_channel.with_open_text path In_channel.input_all

let lines_of_file path =
  In_channel.with_open_text path In_channel.input_lines

let file_to_html file =
  read_entire_file file
    |> Omd.of_string
    |> Omd.to_html

let to_html root =
  traverse_directory root
    |> List.map (fun x -> x |> file_to_html |> wrap_in_article)
    |> String.concat "\n\n\n"

let list root =
  traverse_directory root
  |> List.filter(fun file ->
      file |> Filename.extension |> String.lowercase_ascii |> String.equal ".md"
    )
  |> List.iter(fun file -> print_endline file)

let safe_filename filename = 
  let r = Str.regexp "[^A-Za-z0-9.-]" in
  Str.global_replace r "_" filename

(* FIXME: isn't cross platform compatible, Filename.dir_sep is a string
   so I can't use String.split_on_char *)
let path_split = String.split_on_char '/'

let rec mkdir_p path = 
  if not (Sys.file_exists path) then begin
    if String.length path > 0 then begin
      mkdir_p (Filename.dirname path)
    end;
    Sys.mkdir path 0o777
  end

let move from to' = Sys.rename from to'

let open_file_with_editor path =
  let editor = Option.value ~default:"vi" (getenv "EDITOR") in
  (* open the temporary file with the default editor *)
  Printf.sprintf "%s %s" editor path
  |> Sys.command
  |> ignore

let find_unique_filename path =
  (* literal copy of what was in perl, not the best for OCaml *)
  let r = Str.regexp "\\.md" in
  let counter = ref 1 in
  let search = ref path in
  while Sys.file_exists !search do
    print_endline ("Possible duplicate issue found:\t" ^ !search);
    let replacement = Printf.sprintf "_%i.md" !counter in
    search := Str.replace_first r replacement path;
    counter := !counter + 1;
  done;
  !search

let open_issue () = 
  (* will create the file *)
  let tmpfile = Filename.temp_file ~temp_dir:"issue" "tmp-" ".md" in
  let open_dir = Filename.concat "issue" "open" in
  (* create the issue/open directory if it doesn't exit *)
  ignore (mkdir_p open_dir);
  open_file_with_editor tmpfile;
  (* check if the file was saved. FIXME: completely pointless since file is
     guaranteed to exist by Filename.temp_file *)
  if Sys.file_exists tmpfile then
    let lines = lines_of_file tmpfile in
    (* extract the title from the contents (first line) *)
    (* TODO: add same regex check as in perl *)
    match safe_list_hd lines with
    | Some title -> 
        let title = title |> String.trim in
        let issue_file = (title |> safe_filename) ^ ".md" in
        let path = Filename.concat open_dir issue_file in
        (* check for filename conflicts and find a unique filename *)
        let unique_path = find_unique_filename path in
        Printf.printf "Moving %s to %s.\n" tmpfile unique_path;
        (* TODO: error handling *)
        ignore (move tmpfile unique_path);
        Printf.printf "Issue saved at: %s\n" unique_path;
    | None -> 
      (* TODO: delete file, since it hasn't been written to *)
      print_endline "Cannot create an issue without a title.\n"
  else
    print_endline "No changes were saved.\n"

(* ENTRYPOINT *)
(* let () = issue_dir () |> to_html |> print_endline *)
let () = open_issue ()
