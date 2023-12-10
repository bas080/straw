open Issue_lib

let with_test_file path contents f =
  File_util.write_entire_file path contents;
  let res = f path in
  Sys.remove (Path.to_string path);
  res

let with_test_dir path f =
  Sys.mkdir (Path.to_string path) 0o777;
  let res = f path in
  ignore (Sys.command ("rm -r " ^ (Path.to_string path)));
  res
