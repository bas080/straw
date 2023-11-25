(* let absolute_path path = 
  let cwd = Sys.getcwd () 
  in Filename.concat cwd path *)

let flat_map (f: 'a -> 'b list) (a : 'a list) : 'b list = 
  a
  |> List.map f
  |> List.flatten

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

let list root = 
  traverse_directory root
  |> List.filter(fun file -> 
      let extension = file |> Filename.extension |> String.lowercase_ascii
      in extension = ".md"
    )
  |> List.iter(fun file -> print_endline file)

let () = issue_dir () |> list
