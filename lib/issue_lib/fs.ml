(* open Containers *)

let rec mkdir_p (path : Path.t) =
  if not (Path.exists path) then begin
    let parent = Path.parent path in
    if not (Path.equal path parent) then begin
      mkdir_p parent
    end;
    Sys.mkdir (Path.to_string path) 0o777
  end

let ls_dir (path : Path.t) = 
  path
  |> Path.to_string
  |> Sys.readdir
  |> Array.to_list
  (* |> List.filter Path.is_symlink *)
  |> List.map (Path.append path)

let rec traverse_directory path =
  if Path.is_directory path 
  then List.concat_map traverse_directory (ls_dir path)
  else [ path ]

let safe_filename filename =
  let r = Str.regexp "[^A-Za-z0-9.-]" in
  Str.global_replace r "_" filename

let read_entire_file path = 
  In_channel.with_open_text (Path.to_string path) In_channel.input_all

let lines_of_file path = 
  In_channel.with_open_text (Path.to_string path) In_channel.input_lines
