open Issue_lib

let assert_failure f =
  try
    f ()
  with
  | Failure _ -> ()
  | e -> raise e

let%test "issue_dir returns the issue dir" =
  let cwd = Path.of_string (Sys.getcwd ()) in
  Util.with_test_dir
    (Path.append cwd "issue")
    (fun path ->
      Path.equal path (Cli.issue_dir ()))

(* NOTE: impossible to test since the project directory is called "issue", so
    it will find that instead. We will test it by changing directory to /, as
    this is guaranteed to fail. *)
let%test_unit "issue_dir fails if the issue directory doesn't exist" =
  Util.with_chdir (Path.of_string "/") (fun _ ->
    assert_failure (fun () ->
      ignore (Cli.issue_dir () : Path.t)))

let%test_unit "init creates the issue directory" =
  let path = Path.of_string "issue" in
  assert (not (Path.exists path));
  Cli.init ();
  assert Path.(exists path && is_directory path);
  Util.rm_r path

let%test_unit "init does not create a new directory if it already exists" =
  let path = Path.of_string "issue" in
  assert (not (Path.exists path));
  Util.with_test_dir path (fun _ ->
    assert Path.(exists path && is_directory path);
    Cli.init ())

let%test_unit "list when there is no issue directory" =
  (* same reasoning as described above for issue_dir *)
  Util.with_chdir (Path.of_string "/") (fun _ ->
    assert_failure Cli.list)

let%expect_test "list when there is an empty issue directory" =
  Util.with_test_dir (Path.of_string "issue") (fun _ ->
    Cli.list ();
    [%expect])

let%expect_test "list when there is issues in a directory" =
  Util.with_test_dir (Path.of_string "issue") (fun path ->
    File_util.write_entire_file (Path.append path "test1.md") "test1";
    File_util.write_entire_file (Path.append path "test2.md") "test2";
    (* no extension, is ignored *)
    File_util.write_entire_file (Path.append path "test2") "test2";
    Cli.list ();
    [%expect {|
      issue/test1.md
      issue/test2.md
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

let%test_unit "open when there is no issue directory" =
  (* FIXME: / makes this unix specific *)
  Util.with_chdir (Path.of_string "/") (fun _ ->
    assert_failure Cli.open_issue)

let%test_unit "open when there is an issue directory, but no open directory" =
  with_test_editor "# Fake issue" (fun _ ->
    Util.with_test_dir (Path.of_string "issue") (fun dir ->
      let open_dir = Path.append dir "open" in
      assert (not (Path.exists open_dir));
      Cli.open_issue ();
      let issue_path = Path.append open_dir "fake_issue.md" in
      assert Path.(exists issue_path && is_file issue_path)))

let%test_unit "open when there is an issue/open directory" =
    with_test_editor ("# Fake issue") (fun _ ->
      Util.with_test_dir (Path.of_string "issue/open") (fun dir ->
        Cli.open_issue ();
        let issue_path = Path.append dir "fake_issue.md" in
        assert Path.(exists issue_path && is_file issue_path)))
