(lang dune 2.7)
(cram enable)

(package
 (name issue)
 (depends
  (ocaml (>= "5.1.1"))
  (fpath (>= "0.7.3"))
  (omd (>= "2.0.0~alpha4"))
  (cmdliner
    (and
      (>= "1.2.0")
      (< "2.0.0")))
  (ppx_inline_test :with-test)))

(generate_opam_files)
