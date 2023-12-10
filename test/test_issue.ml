open Issue_lib

module Util = Issue_lib_test.Util

let test_path () =
  let root = Path.of_string (Sys.getcwd()) in
  Util.with_test_dir (Path.append root "open") (fun open_dir ->
    let path = Path.append open_dir "issue.md" in
    Util.with_test_file path "# testing" (fun path ->
      let issue = Issue.from_path ~root path in
      Alcotest.(check string) "is same"
        Path.(to_string (concat root path))
        (Path.to_string (Issue.path issue))))

let test_from_title () =
  let root = Path.of_string (Sys.getcwd ()) in
  let issue = Issue.from_title ~root "open" "testing" in
  Alcotest.(check string) "is same"
    Path.(to_string (concat root (of_string "open/testing.md")))
    (Path.to_string (Issue.path issue))

let test_title () =
  let root = Path.of_string (Sys.getcwd ()) in
  Util.with_test_dir (Path.append root "open") (fun open_dir ->
    let path = Path.append open_dir "issue.md" in
    Util.with_test_file path "testing" (fun path ->
      let issue = Issue.from_path ~root path in
      Alcotest.(check string) "is same" "testing" (Issue.title issue)))

let test_title_when_empty_file () =
  let root = Path.of_string (Sys.getcwd ()) in
  Util.with_test_dir (Path.append root "open") (fun open_dir ->
    let path = Path.append open_dir "issue.md" in
    let issue = Issue.from_path ~root path in
    Alcotest.(check string) "is same" "" (Issue.title issue))

let test_category () =
  let root = Path.of_string (Sys.getcwd ()) in
  Util.with_test_dir (Path.append root "open") (fun open_dir ->
    let path = Path.append open_dir "issue.md" in
    Util.with_test_file path "# testing" (fun path ->
      let issue = Issue.from_path ~root path in
      Alcotest.(check string) "is same" "open" (Issue.category issue)))

let test_all_issues () =
  let root = Path.of_string (Sys.getcwd ()) in
  Util.with_test_dir (Path.append root "open") (fun open_dir ->
    let files = List.map (Path.append open_dir) ["a.md"; "b.md"; "c.md"] in
    (* write a set of files *)
    List.iter (fun path -> File_util.write_entire_file path "test") files;
    let issues = Issue.all_issues root in
    Alcotest.(check (list string)) "same list"
      ["test"; "test"; "test"]
      (List.map Issue.title issues);
    Alcotest.(check (list string)) "same list"
      (List.map Path.to_string files)
      (List.sort String.compare
        (List.map (fun x -> Path.to_string (Issue.path x)) issues)))

let contains s1 s2 =
  let re = Str.regexp s2
  in
    try ignore (Str.search_forward re s1 0); true
    with Not_found -> false

let test_to_html () =
  let root = Path.of_string (Sys.getcwd ()) in
  Util.with_test_dir (Path.append root "open") (fun open_dir ->
    Util.with_test_file
      (Path.append open_dir "to_html.md")
      "hello @mike\nhello #joe\nhello robert\n" (* https://youtu.be/UuSZ37vMIks?si=_F0-lHat8WayFDzM *)
      (fun path ->
        let html = Issue.to_html (Issue.from_path ~root path) in
        (* check contains links *)
        Alcotest.(check bool) "contains hello <a>@mike</a>" true
          (contains html {|hello <a.*class="issue-mention".*@mike|});
        Alcotest.(check bool) "contains hello <a>#joe</a></p>" true
          (contains html {|hello <a.*class="issue-hashtag".*joe|});
        (* Alcotest.(check bool) "contains hello <a>robert</a>" true
          (contains html {|hello <a.*class="issue-directory".*robert|}); *)
        (* check contains article *)
        Alcotest.(check bool) "contains <article>" true
          (contains html "<article>")))

let tests =
  let open Alcotest in
  [
    "Issue.path", [
      test_case "Path is the absolute version of what was given" `Quick test_path
    ];
    "Issue.from_title", [
      test_case "Created issue is correct when given only title" `Quick test_from_title
    ];
    "Issue.title", [
      test_case "Returns the first line of the file" `Quick test_title
    ];
    "Issue.category", [
      test_case "Category is correct for valid paths" `Quick test_category
    ];
    "Issue.all_issues", [
      test_case "Returns all issues in a directory" `Quick test_all_issues
    ];
    "Issue.to_html", [ test_case "Generates expected HTML" `Quick test_to_html ];
  ]
