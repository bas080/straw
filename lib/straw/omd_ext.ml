module Block = struct
  (* taken from https://github.com/ocaml/omd/blob/373e3f80e48001a62daf4072373ad3aa589ca65f/src/ast_block.ml#L62 *)
  let rec map ~f ?(concat = true) =
    let open Omd in
    (* wrap f to handle Concat *)
    let rec f' = function
      | Concat (attr, xs) as c ->
        if concat then Concat (attr, List.map f' xs) else f c
      | _ as inline -> f inline
    in
    function
    | Paragraph (attr, x) -> Paragraph (attr, f' x)
    | List (attr, ty, sp, bl) ->
      List (attr, ty, sp, List.map (List.map (map ~f:f')) bl)
    | Blockquote (attr, xs) -> Blockquote (attr, List.map (map ~f:f') xs)
    | Heading (attr, level, text) -> Heading (attr, level, f' text)
    | Definition_list (attr, l) ->
      let elt { term; defs } =
        { term = f' term; defs = List.map f' defs }
      in
      Definition_list (attr, List.map elt l)
    | Table (attr, headers, rows) ->
      Table
        ( attr
        , List.map (fun (header, alignment) -> (f' header, alignment)) headers
        , List.map (List.map f') rows)
    (* we dont process the rest *)
    | Thematic_break _ | Code_block _ | Html_block _ as x -> x

  let rec find_map ~f ?(concat = true) =
    let open Omd in
    let rec f' = function
      | Concat (_, xs) as c ->
        if concat then List.find_map f' xs else f c
      | _ as inline -> f inline
    in
    function
    | Paragraph (_, x) | Heading (_, _, x) -> f' x
    | List (_, _, _, xs) ->
      List.find_map (List.find_map (find_map ~f:f')) xs
    | Blockquote (_, xs) ->
      List.find_map (find_map ~f:f') xs
    (* TODO: definiton_list, table *)
    | _ -> None

  let find ~f = find_map ~f:(fun x -> if f x then Some x else None)

  let iter ~f ?concat block = map ?concat ~f:(fun x -> f x; x) block |> ignore
end

module Document = struct
  let map ~f = List.map f
  let iter ~f = List.iter f
  let find ~f = List.find_opt f
  let find_map ~f = List.find_map f
end

let inline_map ~f ?concat = Document.map ~f:(Block.map ~f ?concat)
let inline_iter ~f ?concat = Document.iter ~f:(Block.iter ~f ?concat)
let inline_find ~f ?concat = List.find_map (Block.find ~f ?concat)
let inline_find_map ~f ?concat = Document.find_map ~f:(Block.find_map ~f ?concat)
