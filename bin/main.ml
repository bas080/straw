open Core
open Issue

let do_hash file = 
  Md5.digest_file_blocking file |> Md5.to_hex |> print_endline

let filename_param = 
  let open Command.Param in
  anon ("filename" %: string)

let open_cmd =
  Command.basic_spec
    ~summary:"open a new issue"
    Command.Spec.empty
    (fun () -> open_issue ())

let list_cmd = 
  Command.basic_spec
    ~summary:"list the current issues"
    Command.Spec.empty
    (fun () -> list (issue_dir ()))

let readme () = "TODO"

let command = 
  Command.group
    ~summary:"Issue management from the CLI"
    ~readme:readme
    ["open", open_cmd; "list", list_cmd]

(* ENTRYPOINT *)
(* let () = issue_dir () |> to_html |> print_endline *)
(* let () = open_issue () *)
let () = Command_unix.run ~version:"1.0" ~build_info:"RWO" command
