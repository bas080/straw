open Issue_lib

let getcwd () = Path.of_string (Sys.getcwd ())

let%test "path returns an absolute path" =
  let root = getcwd () in
  Util.with_test_dir (Path.append root "open") (fun open_dir ->
    let path = Path.append open_dir "issue.md" in
    Util.with_test_file path "# testing" (fun path ->
      let issue = Issue.from_path ~root path in
      String.equal
        Path.(to_string (concat root path))
        (Path.to_string (Issue.path issue))))

let%test "created issue is correct when given only a title" =
  let root = getcwd () in
  let issue = Issue.from_title ~root "open" "testing" in
  String.equal
      Path.(to_string (concat root (of_string "open/testing.md")))
      (Path.to_string (Issue.path issue))

let%test "title returns the first found text in the file" =
  let root = getcwd () in
  Util.with_test_dir (Path.append root "open") (fun open_dir ->
    let path = Path.append open_dir "issue.md" in
    (* add a few newlines to check they will be ignored*)
    Util.with_test_file path "\n\n\ntesting" (fun path ->
      let issue = Issue.from_path ~root path in
      Option.fold ~none:false
        ~some:(fun title -> String.equal "testing" title)
        (Issue.title issue)))

let%test "title returns a default if no text in file" =
  let root = getcwd () in
  Util.with_test_dir (Path.append root "open") (fun open_dir ->
    let path = Path.append open_dir "issue.md" in
    Util.with_test_file path "" (fun path ->
      let issue = Issue.from_path ~root path in
      Option.is_none (Issue.title issue)))


(* FIXME: really crap test *)
let%test "category exists for a valid path" =
  let root = getcwd () in
  Util.with_test_dir (Path.append root "open") (fun open_dir ->
    let path = Path.append open_dir "issue.md" in
    Util.with_test_file path "# testing" (fun path ->
      let issue = Issue.from_path ~root path in
      String.equal "open" (Issue.category issue)))

let%test "all_issues returns all issues in a directory" =
  let root = getcwd () in
  Util.with_test_dir (Path.append root "open") (fun open_dir ->
    let files = List.map (Path.append open_dir) ["a.md"; "b.md"; "c.md"] in
    List.iter (fun path -> File_util.write_entire_file path "test") files;
    let issues = Issue.all_issues root in
    List.equal String.equal
      ["test"; "test"; "test"]
      (List.filter_map Issue.title issues)
    && List.equal String.equal
      (List.map Path.to_string files)
      (List.sort String.compare
        (List.map (fun x -> Path.to_string (Issue.path x)) issues)))

let contains s1 s2 =
  let re = Str.regexp s2
  in
    try ignore (Str.search_forward re s1 0); true
    with Not_found -> false

(* this would be better suited to an expect test *)
let%test "to_html generates expected HTML" =
    let root = getcwd () in
    Util.with_test_dir (Path.append root "open") (fun open_dir ->
      Util.with_test_file
        (Path.append open_dir "to_html.md")
        "hello @mike\nhello #joe\nhello robert\n" (* https://youtu.be/UuSZ37vMIks?si=_F0-lHat8WayFDzM *)
        (fun path ->
          let html = Issue.to_html (Issue.from_path ~root path) in
          (* check contains links *)
          contains html {|hello <a.*class="issue-mention".*@mike|}
          && contains html {|hello <a.*class="issue-hashtag".*joe|}
          (* check contains article *)
          && contains html "<article>"))
