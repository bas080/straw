open Straw

let assert_failure f =
  try
    f ()
  with
  | Failure _ -> ()
  | e -> raise e

let%test "straw_dir returns the straw dir" =
  let cwd = Path.of_string (Sys.getcwd ()) in
  Util.with_test_dir
    (Path.append cwd "straw")
    (fun path ->
      Path.equal path (Cli.straw_dir ()))

(* NOTE: impossible to test since the project directory is called "straw", so
    it will find that instead. We will test it by changing directory to /, as
    this is guaranteed to fail. *)
let%test_unit "straw_dir fails if the straw directory doesn't exist" =
  Util.with_chdir (Path.of_string "/") (fun _ ->
    assert_failure (fun () ->
      ignore (Cli.straw_dir () : Path.t)))

let%test_unit "init creates the straw directory" =
  let path = Path.of_string "straw" in
  assert (not (Path.exists path));
  Cli.init ();
  assert Path.(exists path && is_directory path);
  Util.rm_r path

let%test_unit "init does not create a new directory if it already exists" =
  let path = Path.of_string "straw" in
  assert (not (Path.exists path));
  Util.with_test_dir path (fun _ ->
    assert Path.(exists path && is_directory path);
    Cli.init ())

let%test_unit "list when there is no straw directory" =
  (* same reasoning as described above for straw_dir *)
  Util.with_chdir (Path.of_string "/") (fun _ ->
    assert_failure Cli.list)

let%expect_test "list when there is an empty straw directory" =
  Util.with_test_dir (Path.of_string "straw") (fun _ ->
    Cli.list ();
    [%expect])

let%expect_test "list when there is files in a directory" =
  Util.with_test_dir (Path.of_string "straw") (fun path ->
    File_util.write_entire_file (Path.append path "test1.md") "test1";
    File_util.write_entire_file (Path.append path "test2.md") "test2";
    (* no extension, is ignored *)
    File_util.write_entire_file (Path.append path "test2") "test2";
    Cli.list ();
    [%expect {|
      straw/test1.md
      straw/test2.md
    |}])

let with_test_editor contents f =
  let fake_editor =
    "#!/usr/bin/env sh\n"
    ^ "echo '" ^ contents ^ "'"
    ^ "> \"$1\""
  in
  Util.with_test_file
    (Path.of_string "./fake-editor")
    fake_editor
    (fun path ->
      (* add +x to file *)
      Unix.chmod (Path.to_string path) 0o777;
      Unix.putenv "EDITOR" (Path.to_string path);
      let ret = f path in
      Unix.putenv "EDITOR" "";
      ret)

let%test_unit "open when there is no straw directory" =
  (* FIXME: / makes this unix specific *)
  Util.with_chdir (Path.of_string "/") (fun _ ->
    assert_failure Cli.open_item)

let%test_unit "open when there is an straw directory, but no open directory" =
  with_test_editor "# Fake straw" (fun _ ->
    Util.with_test_dir (Path.of_string "straw") (fun dir ->
      let open_dir = Path.append dir "open" in
      assert (not (Path.exists open_dir));
      Cli.open_item ();
      let straw_path = Path.append open_dir "fake_straw.md" in
      assert Path.(exists straw_path && is_file straw_path)))

let%test_unit "open when there is an straw/open directory" =
    with_test_editor ("# Fake straw") (fun _ ->
      Util.with_test_dir (Path.of_string "straw/open") (fun dir ->
        Cli.open_item ();
        let straw_path = Path.append dir "fake_straw.md" in
        assert Path.(exists straw_path && is_file straw_path)))
