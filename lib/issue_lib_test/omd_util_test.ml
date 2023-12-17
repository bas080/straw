open Issue_lib;;

let%test_unit "title_of_doc various inlines" =
  let tester test =
    Printf.eprintf "\twith %s\n" test;
    assert (
      Omd.of_string test
      |> Omd_util.title_of_doc
      |> Option.fold ~none:false ~some:(String.equal "title"))
  in
  List.iter tester
    [ {|title|}
    ; {|  title |}
    ; {|# title|}
    ; {|[title](https://example.com)|}
    ; {|`title`|}
    ; {|_title_|}
    ; {|__title__|}
    ; {|[_title_](https://example.com)|}
    ; {|[__title__](https://example.com)|}
    ; {|[`title`](https://example.com)|}
    ]

let%test "title_of_doc handles empty links" =
  Omd.of_string {|[](https://example.com)|}
  |> Omd_util.title_of_doc
  |> Option.is_none

let%test "title_of_doc handles empty headings" =
  Omd.of_string {|# |}
  |> Omd_util.title_of_doc
  |> Option.is_none

let%test "title_of_doc handles empty code" =
  Omd.of_string {|``|}
  |> Omd_util.title_of_doc
  (* will return ``, i'm ok with this case since the markdown parser
     seems to think its just plain text. *)
  |> Option.fold ~none:false ~some:(String.equal "``")

let%test "extract_links extracts @ from text" =
  match Omd_util.extract_links [] "hello @joe" with
  | [Omd.Text (_, text); Omd.Link (_, { label = Omd.Text (_, link); _ })] ->
    String.equal "hello " text
    && String.equal "@joe" link
  | _ -> false

let%test "extract_links extracts # from text" =
    match Omd_util.extract_links [] "hello #mike" with
    | [Omd.Text (_, text); Omd.Link (_, { label = Omd.Text (_, link); _ })] ->
      String.equal "hello " text
      && String.equal "#mike" link
    | _ -> false
