open Core
module Unix = Core_unix
module Sys = Sys_unix

(* FIXME: what if we don't find it? *)
let rec find_parent_directory_with_file target_file start_dir =
  let target_file = Filename.concat start_dir target_file
  in
    if Sys.is_directory_exn target_file then
      start_dir
    else
      (* Move one dir up and try again *)
      Filename.dirname start_dir
      |> find_parent_directory_with_file target_file

let parent_dir () =
  let start = Core_unix.getcwd ()
  (* TODO: make env variable with default *)
  in let target = "issue"
  in find_parent_directory_with_file target start

let issue_dir () =
  let dir = parent_dir ()
  in Filename.concat dir "issue"

let rec traverse_directory path =
  if Sys.is_directory_exn path then
    Sys.readdir path
    |> Array.to_list
    |> List.concat_map ~f:(fun file ->
        Filename.concat path file
        |> traverse_directory
    )
  else
    [path]

(* let wrap_in_article issue_html =
  "<article>" ^ issue_html ^ "</article>" *)

(* let read_entire_file path =
  In_channel.with_file path ~f:In_channel.input_all *)

let lines_of_file path =
  In_channel.with_file path ~f:In_channel.input_lines

(* let file_to_html file =
  read_entire_file file
  |> Omd.of_string
  |> Omd.to_html *)

(* let to_html root =
  traverse_directory root
  |> List.map ~f:(fun x -> x |> file_to_html |> wrap_in_article)
  |> String.concat ~sep:"\n\n\n" *)

let is_md_file path = 
  Filename.split_extension path
  |> Tuple2.get2
  |> Option.for_all ~f:(fun ext -> ext |> String.lowercase |> String.equal "md")

let list root =
  traverse_directory root
  |> List.filter ~f:is_md_file
  |> List.iter ~f:(fun file -> print_endline file)

let safe_filename filename = 
  let r = Str.regexp "[^A-Za-z0-9.-]" in
  Str.global_replace r "_" filename

let move from to' = Core_unix.rename ~src:from ~dst:to'

let open_file_with_editor path =
  let editor = Core.Sys.getenv("EDITOR") |> Option.value ~default:"vi" in
  (* open the temporary file with the default editor *)
  sprintf "%s %s" editor (Filename.quote path)
  |> Sys.command
  |> ignore

let find_unique_filename path =
  (* literal copy of what was in perl, not the best for OCaml *)
  let r = Str.regexp "\\.md" in
  let counter = ref 1 in
  let search = ref path in
  while Sys.file_exists_exn !search do
    print_endline ("Possible duplicate issue found:\t" ^ !search);
    let replacement = sprintf "_%i.md" !counter in
    search := Str.replace_first r replacement path;
    counter := !counter + 1;
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
      let title = String.strip title in
      let issue_file = (safe_filename title) ^ ".md" in
      let path = Filename.concat open_dir issue_file in
      (* check for filename conflicts and find a unique filename *)
      let unique_path = find_unique_filename path in
      printf "Moving %s to %s.\n" tmpfile unique_path;
      (* TODO: error handling *)
      ignore (move tmpfile unique_path);
      printf "Issue saved at: %s\n" unique_path;
  | None -> 
    print_endline "No changes were saved.";
    (* cleanup empty tempfile *)
    Sys.remove tmpfile;
    (* exit with non-standard exit code *)
    exit 1

let edit _root = ()
let search _root = ()

let count_files path = 
  traverse_directory path
  |> List.filter ~f:(
    fun file -> (Sys.is_file_exn file) && (is_md_file file)
  )
  |> List.length

let status () = 
  let root = issue_dir () in
  Sys.ls_dir root
  |> List.map ~f:(fun dir -> (dir, count_files (Filename.concat root dir)))
  |> List.iter ~f:(fun (dir, count) -> printf "%s\t%i\n" dir count)
let show _root = ()

let validate _root = ()
let html _root = ()
