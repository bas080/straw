module Block = struct
  type 'a t = 'a Omd.block
  type 'a inline = 'a Omd.inline

  (* taken from https://github.com/ocaml/omd/blob/373e3f80e48001a62daf4072373ad3aa589ca65f/src/ast_block.ml#L62 *)
  let rec map ~f = function
  | Omd.Paragraph (attr, x) -> Omd.Paragraph (attr, f x)
  | Omd.List (attr, ty, sp, bl) ->
    Omd.List (attr, ty, sp, List.map (List.map (map ~f)) bl)
  | Omd.Blockquote (attr, xs) -> Omd.Blockquote (attr, List.map (map ~f) xs)
  | Omd.Thematic_break attr -> Omd.Thematic_break attr
  | Omd.Heading (attr, level, text) -> Omd.Heading (attr, level, f text)
  | Omd.Definition_list (attr, l) ->
    let f { Omd.term; defs } =
      { Omd.term = f term; defs = List.map f defs }
    in
    Definition_list (attr, List.map f l)
  | Omd.Code_block (attr, label, code) -> Omd.Code_block (attr, label, code)
  | Omd.Html_block (attr, x) -> Omd.Html_block (attr, x)
  | Omd.Table (attr, headers, rows) ->
    Table
      ( attr
      , List.map (fun (header, alignment) -> (f header, alignment)) headers
      , List.map (List.map f) rows)

  let iter ~f doc = map ~f:(fun x -> f x; x) doc |> ignore
end

module Document = struct
  type t = Omd.doc
  type attr = Omd.attributes

  let map ~f = List.map f
  let iter ~f = List.iter f
end

let inline_map ~f =
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
