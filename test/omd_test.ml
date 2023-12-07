open Issue_lib

let print_inline md =
  Printf.printf "==> ";
  match md with
  | Omd.Text (_, s) -> Printf.printf "text: %s\n" s
  | Omd.Link (_, link) ->
    Printf.printf "link: %s\n" link.destination
  | Omd.Code (_, s) -> Printf.printf "code: %s\n" s
  | _ -> ()

let print_markdown = Omd_ext.inline_iter ~f:print_inline

let rs = [
  Str.regexp {|@\([A-Za-z0-9]+\)|};
  Str.regexp {|\([A-Za-z0-9-]+\)#|};
  Str.regexp {|\(/[A-Za-z0-9-]+\)|};
]

let extract_links attr text =
  let r = List.hd rs in
  Str.full_split r text
  |> List.map (function
      | Str.Delim(s) ->
        let label = Omd.Text (attr, s) in
        let title = Some ("Search mention " ^ s) in
        Omd.Link (
          [("class", "issue-mention")],
          { Omd.title; label; destination = "#" })
      | Str.Text (s) ->
        Omd.Text (attr, s))

let md_file_path = "test.md"
let () =
  Printf.printf "==> Running under %s\n" (Sys.getcwd ());
  let md_file = In_channel.with_open_text md_file_path In_channel.input_all in
  Printf.printf "============ ORIGINAL ============\n";
  print_endline md_file;
  let doc = Omd.of_string md_file in
  Printf.printf "============ PRINTED ============\n";
  print_markdown doc;
  Printf.printf "========== TRANSFORMED ==========\n";
  let f = function
  | Omd.Text (attr, s) as t ->
    let links = extract_links attr s in
    if List.is_empty links
    then t (* no links, dont change text *)
    else Omd.Concat (attr, extract_links attr s)
  | _ as x -> x
  in
  let new_doc = Omd_ext.inline_map ~f doc in
  print_endline (Omd.to_html new_doc);

