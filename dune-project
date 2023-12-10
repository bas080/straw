(lang dune 2.1)

(package
 (name issue)
 (depends
  fpath
  omd
  cmdliner
  (ppx_inline_test :with-test)))

(generate_opam_files)
