open Issue_lib

let%test "/ is a root" = Path.(is_root (of_string "/"))
let%test "/home is not a root" = not Path.(is_root (of_string "/home"))

let%test "convert to and from a string" =
  String.equal "/home" Path.(to_string (of_string "/home"))

(* TODO: come up with more test cases for this *)
let%test "to_quoted returns a quoted string" =
  String.equal "'/home'" Path.(to_quoted (of_string "/home"))

let%test "append adds a segment at the end of the path" =
  String.equal "/home/rage"
    Path.(to_string (append (of_string "/home") "rage"))

let%test "append absolute paths" =
  try
    ignore Path.(to_string (append (of_string "/home") "/home/rage"));
    false
  with Invalid_argument msg ->
    String.equal msg {|"/home/rage": invalid segment|}

let%test "concat an absolute and a relative path" =
  String.equal "/home/rage"
    Path.(to_string (concat (of_string "/home") (of_string "rage")))

let%test "concat two absolute paths" =
  String.equal "/home/rage"
    Path.(to_string (concat (of_string "/home") (of_string "/home/rage")))

let%test "parent" =
  String.equal "/home/"
    Path.(to_string (parent (of_string "/home/rage")))

let%test "parent of a root" =
  String.equal "/" Path.(to_string (parent (of_string "/")))

let%test "split path into parts" =
  List.equal String.equal
    ["home"; "rage"]
    Path.(parts (of_string "/home/rage"))

let%test "convert absolute to a relative path" =
  let root = Path.of_string "/home" in
  String.equal
    "rage"
    Path.(to_string (to_relative ~root (of_string "/home/rage")))

let%test "convert relative to absolute path" =
  let cwd = Sys.getcwd () in
  String.equal (cwd ^ "/rage")
    Path.(to_string (to_absolute (of_string "rage")))

let%test "extension returns the file extension" =
  Option.equal String.equal
    (Some ".md")
    Path.(extension (of_string "test.md"))

let%test "extension returns nothing when there is no extension" =
  Option.is_none Path.(extension (of_string "test"))

let%test "has_extension returns true if the file has the extension" =
  Path.(has_extension ~ext:"md" (of_string ("test.md")))

let%test "has_extension with different extensions" =
  not Path.(has_extension ~ext:"md" (of_string "test.txt"))

let%test "has_extension with no extension" =
  not Path.(has_extension ~ext:"md" (of_string "test"))

(* TODO: move file utils over *)
let%test "is_directory returns true if its a directory" =
  Util.with_test_dir (Path.of_string "./test-dir")
    (fun path -> Path.is_directory path)

let%test "is_directory returns false if its a file" =
  Util.with_test_file (Path.of_string "./test-file") "test"
    (fun path -> not (Path.is_directory path))

let%test "is_file returns true for a regular file" =
  Util.with_test_file (Path.of_string "./test-file") "test"
    (fun path -> Path.is_file path)

let%test "is_file returns false for a directory" =
  Util.with_test_dir (Path.of_string "./test-dir")
    (fun path -> not (Path.is_file path))

let%test "exists returns true if a file exists" =
  Util.with_test_file (Path.of_string "./test-file") "test"
    (fun path -> Path.exists path)

let%test "exists returns true if the directory exists" =
  Util.with_test_dir (Path.of_string "./test-dir")
    (fun path -> Path.exists path)

let%test "exists returns false if there is nothing at the file path" =
  not (Path.(exists (of_string "missing")))

let%test "equal is true if the files are exactly equal" =
  Path.(equal (of_string "test.md") (of_string "test.md"))

(* TODO: use generative testing for this *)
let%test "equal is false for every other case" =
  not Path.(equal (of_string "test.md") (of_string "test.txt"))

let%test "compare" =
  (* lt *)
  (Path.(compare (of_string "aaaa") (of_string "zzzz")) = -1)
  (* eq *)
  && (Path.(compare (of_string ("test")) (of_string "test")) = 0)
  (* gt *)
  && (Path.(compare (of_string "zzzz") (of_string "aaaa")) = 1)
