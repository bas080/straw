open Straw

let rm_r path =
  ignore (Sys.command ("rm -r " ^ (Path.to_string path)) : int)

let with_test_file path contents f =
  File_util.write_entire_file path contents;
  let res = f path in
  Sys.remove (Path.to_string path);
  res

let with_test_dir path f =
  File_util.mkdir_p path;
  let res = f path in
  (* cleanup *)
  rm_r path;
  res

let with_chdir path f =
  let cwd = Sys.getcwd () in
  Sys.chdir (Path.to_string path);
  f path;
  Sys.chdir cwd
