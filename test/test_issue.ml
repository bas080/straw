open Issue_lib

let test_category () =
  let root = Path.of_string (Sys.getcwd ()) in
  Util.with_test_dir (Path.append root "open") (fun open_dir ->
    let path = Path.append open_dir "missing.md" in
    Util.with_test_file path "# testing" (fun path ->
      let issue = Issue.from_path ~root path in
      Alcotest.(check string) "is same" "open" (Issue.category issue)))

let tests =
  let open Alcotest in
  [
    "Issue.category", [
      test_case "Category is correct for valid paths" `Quick test_category
    ]
  ]
