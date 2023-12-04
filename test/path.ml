open Issue_lib

let with_test_file path contents f =
  File_util.write_entire_file path contents;
  let res = f path in
  Sys.remove (Path.to_string path);
  res

let with_test_dir path f =
  Sys.mkdir (Path.to_string path) 0o777;
  let res = f path in
  Sys.rmdir (Path.to_string path);
  res

let test_is_slash_root () =
  Alcotest.(check bool) "is true" true (Path.is_root (Path.of_string "/"))

let test_home_not_root () =
  Alcotest.(check bool) "is false" false (Path.is_root (Path.of_string "/home"))

let test_to_from_string () =
  Alcotest.(check string) "same string" "/home" Path.(to_string (of_string "/home"))

let test_to_quoted () =
  Alcotest.(check string) "same string" "'/home'" Path.(to_quoted (of_string "/home"))

let test_append () =
  Alcotest.(check string) "same string" "/home/rage"
    Path.(to_string (append (of_string "/home") "rage"))

let test_append_absolute () =
  Alcotest.(check_raises "throws Invalid_argument"
    (Invalid_argument "\"/home/rage\": invalid segment")
    (fun () ->
      ignore (Path.(to_string (append (of_string "/home") "/home/rage")))))

let test_concat () =
  Alcotest.(check string) "same string" "/home/rage"
    Path.(to_string (concat (of_string "/home") (of_string "rage")))

let test_concat_absolute () =
  Alcotest.(check string) "same string" "/home/rage"
    Path.(to_string (concat (of_string "/home") (of_string "/home/rage")))

let test_parent () =
  Alcotest.(check string) "same string" "/home/"
    Path.(to_string (parent (of_string "/home/rage")))

let test_parent_root () =
  Alcotest.(check string) "same string" "/"
    Path.(to_string (parent (of_string "/")))

let test_parts () =
  Alcotest.(check (list string)) "same lists" ["home"; "rage"]
    Path.(parts (of_string "/home/rage"))

let test_to_relative () =
  Alcotest.(check string) "same string" "rage"
    Path.(to_string (to_relative ~root:(of_string "/home") (of_string "/home/rage")))

let test_to_absolute () =
  let cwd = Sys.getcwd () in
  Alcotest.(check string) "same string" (cwd ^ "/rage")
    Path.(to_string (to_absolute (of_string "rage")))

let test_extension () =
  Alcotest.(check (option string)) "same option" (Some ".md")
    Path.(extension (of_string "test.md"))

let test_extension_when_missing () =
  Alcotest.(check (option string)) "same option" None
    Path.(extension (of_string "test"))

let test_has_extension () =
  Alcotest.(check bool) "same bool" true
    Path.(has_extension ~ext:"md" (of_string "test.md"))

let test_has_extension_when_different () =
  Alcotest.(check bool) "same bool" false
    Path.(has_extension ~ext:"md" (of_string "test.txt"))

let test_has_extension_when_missing () =
  Alcotest.(check bool) "same bool" false
    Path.(has_extension ~ext:"md" (of_string "test"))

let test_is_directory () =
with_test_dir (Path.of_string "./test-dir")
  (fun path ->
    Alcotest.(check bool) "same bool" true (Path.is_directory path))

let test_is_directory_when_file () =
  with_test_file (Path.of_string "./test-file") "test"
    (fun path ->
      Alcotest.(check bool) "same bool" false (Path.is_directory path))

let test_is_file () =
  with_test_file (Path.of_string "./test-file") "test"
    (fun path ->
      Alcotest.(check bool) "same bool" true (Path.is_file path))

let test_is_file_when_directory () =
  with_test_dir (Path.of_string "./test-dir")
    (fun path ->
      Alcotest.(check bool) "same bool" false Path.(is_file path))

let test_exists_file () =
  with_test_file (Path.of_string "./test-file") "test"
    (fun path ->
      Alcotest.(check bool) "same bool" true (Path.exists path))

let test_exists_directory () =
  with_test_dir (Path.of_string "./test-dir")
    (fun path ->
      Alcotest.(check bool) "same bool" true (Path.exists path))

let test_exists_missing () =
  Alcotest.(check bool) "same bool" false
    Path.(exists (of_string "missing"))

let test_equal () =
  Alcotest.(check bool) "same bool" true
    Path.(equal (of_string "test.md") (of_string "test.md"))

let test_not_equal () =
  Alcotest.(check bool) "same bool" false
    Path.(equal (of_string "test.md") (of_string "test.txt"))

let test_compare_lt () =
  Alcotest.(check int) "same int" (-1)
    Path.(compare (of_string "aaaa") (of_string "zzzz"))

let test_compare_eq () =
  Alcotest.(check int) "same int" 0
    Path.(compare (of_string "test") (of_string "test"))

let test_compare_gt () =
  Alcotest.(check int) "same int" 1
    Path.(compare (of_string "zzzz") (of_string "aaaa"))

let () =
  let open Alcotest in
  run "Path" [
    "is-root", [
      test_case "Check if / is root" `Quick test_is_slash_root;
      test_case "Check that /home is not root" `Quick test_home_not_root;
    ];
    "to-from-string", [ test_case "String to and from" `Quick test_to_from_string ];
    "to-quoted", [ test_case "Converts a string to its quoted form" `Quick test_to_quoted ];
    "append", [
      test_case "Appends a segment to the end of the path" `Quick test_append;
      test_case "Throws when using an absolute path" `Quick test_append_absolute;
    ];
    "concat", [
      test_case "Concatenates two paths together" `Quick test_concat;
      test_case "Handles absolute paths correctly" `Quick test_concat_absolute;
    ];
    "parent", [
      test_case "Returns the parent of the give path" `Quick test_parent;
      test_case "Does nothing if the path is root" `Quick test_parent_root;
    ];
    "parts", [ test_case "Splits a path into its parts" `Quick test_parts ];
    "to-relative", [ test_case "Converts to a relative path given a root" `Quick test_to_relative ];
    "to-absolute", [ test_case "Converts a relative path to absolute" `Quick test_to_absolute ];
    "extension", [
      test_case "Returns the extension of the file when it exists" `Quick test_extension;
      test_case "Returns nothing if the extension doesnt exist" `Quick test_extension_when_missing;
    ];
    "has-extension", [
      test_case "Returns true if the extension exists" `Quick test_has_extension;
      test_case "Returns false if the extension is different" `Quick test_has_extension_when_different;
      test_case "Returns false if the extension is missing" `Quick test_has_extension_when_missing;
    ];
    "is-directory", [
      test_case "Returns true if the reference is a directory" `Quick test_is_directory;
      test_case "Returns false if the reference is a file" `Quick test_is_directory_when_file;
    ];
    "is-file", [
      test_case "Returns true if the reference is a file" `Quick test_is_file;
      test_case "Returns false if the reference is a directory" `Quick test_is_file_when_directory;
    ];
    "exists", [
      test_case "Returns true if file exists" `Quick test_exists_file;
      test_case "Returns true if directory exists" `Quick test_exists_directory;
      test_case "Returns false if the reference doesnt exist" `Quick test_exists_missing;
    ];
    "equal", [
      test_case "Returns true if the file paths are the same" `Quick test_equal;
      test_case "Returns false if the file paths are different" `Quick test_not_equal;
    ];
    "compare", [
      test_case "Returns -1 if the path is smaller" `Quick test_compare_lt;
      test_case "Returns 0 if the paths are equal" `Quick test_compare_eq;
      test_case "Returns 1 if the path is larger" `Quick test_compare_gt;
    ];
  ]
