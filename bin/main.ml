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

let search_cmd =
  Command.basic_spec
    ~summary:"keyword search through issues"
    Command.Spec.empty
    (fun () -> working_on_it "edit")

let status_cmd =
  Command.basic_spec
    ~summary:"show the number of files in each issue category"
    Command.Spec.empty
    (fun () -> status ())

let html_cmd = 
  Command.basic_spec
    ~summary:"print issues as HTML"
    Command.Spec.empty
    (fun () -> html ())

let validate_cmd =
  Command.basic_spec
    ~summary:"check issues are valid"
    Command.Spec.empty
    (fun () -> validate ())

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
      "search", search_cmd;
      "status", status_cmd;
      "html", html_cmd;
      "validate", validate_cmd;
    ]

(* ENTRYPOINT *)
(* let () = issue_dir () |> to_html |> print_endline *)
(* let () = open_issue () *)
let () = Command_unix.run ~version:"1.0" ~build_info:"RWO" command
