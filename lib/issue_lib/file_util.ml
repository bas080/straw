let move ~src ~dest = Sys.rename (Path.to_string src) (Path.to_string dest)

let mkdir ?(perm = 0o777) (path: Path.t) =
  try
    Unix.mkdir (Path.to_string path) perm
  with
  | Unix.Unix_error (Unix.EEXIST, _, _) -> ()

let rec mkdir_p (path : Path.t) =
  if not (Path.exists path) then begin
    let parent = Path.parent path in
    if not (Path.equal path parent) then begin
      mkdir_p parent
    end;
    mkdir path
  end

let ls_dir (path : Path.t) =
  path
  |> Path.to_string
  |> Sys.readdir
  |> Array.to_list
  |> List.map (Path.append path)

let rec traverse_directory path =
  if Path.is_directory path
  then List.concat_map traverse_directory (ls_dir path)
  else [ path ]

let safe_filename filename =
  let r = Str.regexp "[^A-Za-z0-9.-]" in
  Str.global_replace r "_" filename

let write_entire_file path content =
  Out_channel.with_open_text
    (Path.to_string path)
    (fun c -> Out_channel.output_string c content)

let read_entire_file path =
  In_channel.with_open_text (Path.to_string path) In_channel.input_all

let lines_of_file path =
  In_channel.with_open_text (Path.to_string path) In_channel.input_lines

let single_line_of_file path =
  In_channel.with_open_text (Path.to_string path) In_channel.input_line
