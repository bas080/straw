(lang dune 3.0)

(package
 (name straw)
 (depends
  (ocaml (>= "5.1.1"))
  (fpath (>= "0.7.3"))
  (omd (>= "2.0.0~alpha4"))
  (cmdliner
    (and
      (>= "1.2.0")
      (< "2.0.0")))
  (ppx_inline_test :with-test)
  (ppx_expect :with-test)))

(generate_opam_files)
