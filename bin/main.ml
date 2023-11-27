open Core
open Issue

let working_on_it cmd =
  printf "Executing '%s' subcommand\n" cmd

let list_cmd = 
  Command.basic_spec
    ~summary:"list the current issues"
    Command.Spec.empty
    (fun () -> list (issue_dir ()))

let open_cmd =
  Command.basic_spec
    ~summary:"open a new issue"
    Command.Spec.empty
    (fun () -> open_issue ())

let edit_cmd =
  Command.basic_spec
    ~summary:"edit an issue"
    Command.Spec.empty
    (fun () -> working_on_it "edit")

let dir_cmd = 
  Command.basic_spec
    ~summary:"show the current issue directory"
    Command.Spec.empty
    (fun () -> print_endline (parent_dir ()))

let status_cmd =
  Command.basic_spec
    ~summary:"show the number of files in each issue category"
    Command.Spec.empty
    (fun () -> status ())

let readme () = "TODO"

let command = 
  Command.group
    ~summary:"Issue management from the CLI"
    ~readme:readme
    [
      "list", list_cmd; "ls", list_cmd;
      "open", open_cmd; 
      "edit", edit_cmd;
      "dir", dir_cmd;
      "status", status_cmd;
    ]

(* ENTRYPOINT *)
(* let () = issue_dir () |> to_html |> print_endline *)
(* let () = open_issue () *)
let () = Command_unix.run ~version:"1.0" ~build_info:"RWO" command
