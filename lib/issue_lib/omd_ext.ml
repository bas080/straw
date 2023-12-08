module Block = struct
  (* taken from https://github.com/ocaml/omd/blob/373e3f80e48001a62daf4072373ad3aa589ca65f/src/ast_block.ml#L62 *)
  let rec map ~f = function
  | Omd.Paragraph (attr, x) -> Omd.Paragraph (attr, f x)
  | Omd.List (attr, ty, sp, bl) ->
    Omd.List (attr, ty, sp, List.map (List.map (map ~f)) bl)
  | Omd.Blockquote (attr, xs) -> Omd.Blockquote (attr, List.map (map ~f) xs)
  | Omd.Heading (attr, level, text) -> Omd.Heading (attr, level, f text)
  | Omd.Definition_list (attr, l) ->
    let f { Omd.term; defs } =
      { Omd.term = f term; defs = List.map f defs }
    in
    Definition_list (attr, List.map f l)
  | Omd.Table (attr, headers, rows) ->
    Table
      ( attr
      , List.map (fun (header, alignment) -> (f header, alignment)) headers
      , List.map (List.map f) rows)
  (* we dont process the rest *)
  | Omd.Thematic_break _ | Omd.Code_block _ | Omd.Html_block _ as x -> x

  let rec find ~f = function
  | Omd.Paragraph (_, x) when f x -> Some x
  | Omd.Heading (_, _, x) when f x -> Some x
  | Omd.List (_, _, _, xs) ->
    List.find_map (List.find_map (find ~f)) xs
  | Omd.Blockquote (_, xs) ->
    List.find_map (find ~f) xs
  (* TODO: definiton_list, table *)
  | _ -> None

  (* let find_map ~f = find ~f:(fun x -> Option.is_some (f x)) *)

  let iter ~f block = map ~f:(fun x -> f x; x) block |> ignore
end

module Document = struct
  let map ~f = List.map f
  let iter ~f = List.iter f
  let find ~f = List.find_opt f
  (* let find_map ~f = List.find_map f *)
end

let inline_map ~f =
  (* TODO: move handling of Omd.Concat to Block *)
  let rec f' = function
  | Omd.Concat (attr, xs) ->
    Omd.Concat (attr, List.map f' xs)
  | _ as inline -> f inline
  in
  Document.map ~f:(Block.map ~f:f')

let inline_iter ~f =
  let rec f' = function
  | Omd.Concat (_, xs) -> List.iter f' xs
  | _ as inline -> f inline
  in
  Document.iter ~f:(Block.iter ~f:f')

let inline_find ~f =
  let rec f' = function
  | Omd.Concat (_, xs) -> List.exists f' xs
  | _ as inline -> f inline
  in
  List.find_map (Block.find ~f:f')

(* let inline_find_map ~f =
  let rec f' = function
  | Omd.Concat (_, xs) -> List.find_map f' xs
  | _ as inline -> f inline
  in
  Document.find_map ~f:(Block.find_map ~f:f') *)
