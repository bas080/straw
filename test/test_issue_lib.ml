let () =
  Alcotest.run "Issue_lib unit tests"
    (List.concat [ Test_path.tests; Test_issue.tests ])
