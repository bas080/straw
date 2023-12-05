(lang dune 2.1)

(package
 (name issue)
 (depends
  fpath
  omd
  cmdliner
  (alcotest :with-test)))

(generate_opam_files)
