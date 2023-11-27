open Core
open Issue

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

let dir_cmd = 
  Command.basic_spec
    ~summary:"show the current issue directory"
    Command.Spec.empty
    (fun () -> dir ())

let readme () = "TODO"

let command = 
  Command.group
    ~summary:"Issue management from the CLI"
    ~readme:readme
    [
      "open", open_cmd; 
      "list", list_cmd; "ls", list_cmd;
      "dir", dir_cmd;
    ]

(* ENTRYPOINT *)
(* let () = issue_dir () |> to_html |> print_endline *)
(* let () = open_issue () *)
let () = Command_unix.run ~version:"1.0" ~build_info:"RWO" command
