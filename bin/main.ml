open Cmdliner
open Straw.Cli

let working_on_it cmd = Printf.eprintf "Executing '%s' subcommand\n" cmd

let init_cmd =
  let doc = "Create the issue directory if it doesn't exist" in
  Cmd.v
    (Cmd.info "init" ~doc)
    Term.(const init $ const ())

let list_cmd =
  Cmd.v
    (Cmd.info "list" ~doc:"List the current issue/note")
    Term.(const list $ const ())

let open_cmd =
  Cmd.v
    (Cmd.info "open" ~doc:"Open a new issue/note")
    Term.(const open_item $ const ())

let dir_cmd =
  Cmd.v
    (Cmd.info "dir" ~doc:"Show the current straw directory")
    Term.(const (fun () -> straw_dir () |> Straw.Path.to_string |> print_endline) $ const ())

let search_cmd =
  Cmd.v
    (Cmd.info "search" ~doc:"Keyword search through issues/notes")
    Term.(const working_on_it $ const "search")

let status_cmd =
  Cmd.v
    (Cmd.info "status" ~doc:"Show the number of files in each category")
    Term.(const status $ const ())

let html_cmd =
  Cmd.v
    (Cmd.info "html" ~doc:"Print issues/notes as HTML")
    Term.(const html $ const ())

let subcommands = [
  init_cmd;
  list_cmd;
  open_cmd;
  dir_cmd;
  search_cmd;
  status_cmd;
  html_cmd;
]

let root_cmd =
  let doc = "Issue management and note keeping from the CLI" in
  let man = [`S "BUGS"; `P "Email bug reports to <bassimhuis@gmail.com>."] in
  let sdocs = Manpage.s_common_options in
  let info = Cmd.info "straw" ~version:"%%VERSION%%" ~doc ~man ~sdocs in
  (* show help when no subcommand is provided *)
  let default = Term.(ret (const (`Help (`Pager, None)))) in
  Cmd.group ~default info subcommands

let () = exit (Cmd.eval root_cmd)
