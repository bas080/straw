open Cmdliner
open Issue_lib.Cli

let working_on_it cmd = Printf.eprintf "Executing '%s' subcommand\n" cmd

let list_cmd =
  Cmd.v
    (Cmd.info "list" ~doc:"List the current issues")
    Term.(const list $ const ())

let open_cmd =
  Cmd.v
    (Cmd.info "open" ~doc:"Open a new issue")
    Term.(const open_issue $ const ())

let dir_cmd =
  Cmd.v
    (Cmd.info "dir" ~doc:"Show the current issue directory")
    Term.(const (fun () -> issue_dir () |> Issue_lib.Path.to_string |> print_endline) $ const ())

let search_cmd =
  Cmd.v
    (Cmd.info "search" ~doc:"Keyword search through issues")
    Term.(const working_on_it $ const "search")

let status_cmd =
  Cmd.v
    (Cmd.info "status" ~doc:"Show the number of files in each issue category")
    Term.(const status $ const ())

let html_cmd =
  Cmd.v
    (Cmd.info "html" ~doc:"Print issues as HTML")
    Term.(const html $ const ())

let subcommands = [
  list_cmd;
  open_cmd;
  dir_cmd;
  search_cmd;
  status_cmd;
  html_cmd;
]

let root_cmd =
  let doc = "Issue management from the CLI" in
  let man = [`S "BUGS"; `P "Email bug reports to <bassimhuis@gmail.com>."] in
  let sdocs = Manpage.s_common_options in
  let info = Cmd.info "issue" ~version:"%%VERSION%%" ~doc ~man ~sdocs in
  (* show help when no subcommand is provided *)
  let default = Term.(ret (const (`Help (`Pager, None)))) in
  Cmd.group ~default info subcommands

let () = exit (Cmd.eval root_cmd)
