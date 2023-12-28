let is_text_empty text = String.(equal empty (trim text))
let text_or_none text =
  if is_text_empty text then None else Some text

let title_of_doc doc =
  let open Omd in
  let rec finder = function
    | Text (_, s) | Code (_, s) -> text_or_none s
    | Link (_, link) -> finder link.label
    | Strong (_, inline) | Emph (_, inline) -> finder inline
    | Concat (_, xs) ->
      List.filter_map finder xs
      |> String.concat ""
      |> text_or_none
    | _ -> None
  in
  Omd_ext.inline_find_map ~concat:false ~f:finder doc

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

let mention_regexp = Str.regexp {|@\([^@ .,;:!?\t\n]+\)|}
let hashtag_regexp = Str.regexp {|#\([^@ .,;:!?\t\n]+\)|}

let extract_links attr text =
  split_links attr ("mention", mention_regexp) text
  |> List.concat_map (
    function
    | Omd.Text (attr, s) -> split_links attr ("hashtag", hashtag_regexp) s
    | x -> [x])

let replace_text_with_links = Omd_ext.inline_map ~concat:true ~f:(function
  | Omd.Text (attr, s) as t ->
    let links = extract_links attr s in
    if List.is_empty links
    then t
    else Omd.Concat (attr, links)
  | x -> x)
