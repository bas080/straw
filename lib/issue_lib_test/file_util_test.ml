open Issue_lib

let%test "safe_filename" =
  List.for_all
    (fun (input, expect) ->
      String.equal (File_util.safe_filename input) expect)
    [
      ("test.md", "test.md");
      ("test-1.md", "test-1.md");
      ("test_1.md", "test_1.md");
      ("test@1.md", "test_1.md");
      ("test#1.md", "test_1.md");
      ("#test1.md", "_test1.md");
      ("#$@!^&", "______");
    ]

let%test "read_entire_file" =
  let path = Path.of_string "read-file.txt" in
  let contents = "this is a test" in
  Util.with_test_file path contents
      (fun path ->
        String.equal contents (File_util.read_entire_file path))

let%test "write_entire_file" =
  let path = Path.of_string "write-file.txt" in
  let content = "this is a test" in
  File_util.write_entire_file path content;
  let ret = String.equal (File_util.read_entire_file path) content in
  Sys.remove (Path.to_string path);
  ret
