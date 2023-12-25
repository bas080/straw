open Straw

let print_inline md =
  Printf.printf "==> ";
  match md with
  | Omd.Text (_, s) -> Printf.printf "text: %s\n" s
  | Omd.Link (_, link) ->
    Printf.printf "link: %s\n" link.destination
  | Omd.Code (_, s) -> Printf.printf "code: %s\n" s
  | _ -> ()

let print_markdown = Omd_ext.inline_iter ~f:print_inline

let mention_regexp = Str.regexp {|@\([A-Za-z0-9]+\)|}
let hashtag_regexp = Str.regexp {|#\([A-Za-z0-9]+\)|}

(* split a string, extracting a list of Omd.Link and Omd.Text *)
let split_links attr (tag, r) text =
  Str.full_split r text
  |> List.map (function
    | Str.Delim (s) ->
      let label = Omd.Text (attr, s) in
      let title = Some ("Search " ^ tag ^ " " ^ s) in
      Omd.Link (
        [("class", "straw-" ^ tag)],
        { Omd.title; label; destination = "#" })
    | Str.Text (s) -> Omd.Text (attr, s))

let extract_links attr text =
  split_links attr ("mention", mention_regexp) text
  |> List.concat_map (
    function
    | Omd.Text (attr, s) -> split_links attr ("hashtag", hashtag_regexp) s
    | x -> [x])

let is_text_empty text = String.(equal empty (trim text))
let text_or_none text =
  if is_text_empty text then None else Some text

let title doc =
  let rec finder = function
    | Omd.Text (_, s) | Omd.Code (_, s) -> text_or_none s
    | Omd.Link (_, link) -> finder link.label
    | Omd.Strong (_, inline) | Omd.Emph (_, inline) -> finder inline
    | Omd.Concat (_, xs) ->
      List.filter_map finder xs
      |> String.concat ""
      |> text_or_none
    | _ -> None
  in
  let text_opt = Omd_ext.inline_find_map doc ~concat:false ~f:finder in
  Option.value text_opt ~default:"Untitled document"

let md_file = {|
#
# [](https://example.com)

# hello [`@mike`](https://example.com)

hello @joe, hello @mike

# #erlang

have you seen the #erlang movie?
|}

let () =
  Printf.printf "==> Running under %s\n" (Sys.getcwd ());
  Printf.printf "============ ORIGINAL ============\n";
  print_endline md_file;
  Printf.printf "============= PRINTED ============\n";
  let doc = Omd.of_string md_file in
  print_markdown doc;
  Printf.printf "=========== TRANSFORMED ==========\n";
  let title = title doc in
  Printf.printf "title would be: '%s'\n" title;
  let f = function
  | Omd.Text (attr, s) as t ->
    let links = extract_links attr s in
    if List.is_empty links
    then t (* no links, dont change text *)
    else Omd.Concat (attr, links)
  | _ as x -> x
  in
  doc
  |> Omd_ext.inline_map ~f
  |> Omd.to_html
  |> print_endline

