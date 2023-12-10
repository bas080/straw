let () =
  Alcotest.run "Issue_lib unit tests"
    (List.concat [ Test_issue.tests ])
