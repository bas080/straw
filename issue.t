#!/usr/bin/env cram

  $ cd $TESTDIR/browser || exit
  > {
  >   npm ci
  >   npm run lint
  >   npm run build
  >   npm t
  > } > /dev/null 2>&1

  $ cd $TESTDIR || exit

  $ dune build
  $ dune install

  $ cd $CRAMTMP || exit

  $ issue --version
  %%VERSION%%

  $ issue init
  Creating issue directory in /tmp/*/issue (glob)

  $ issue dir
  /tmp/*/issue (glob)

  $ EDITOR="$TESTDIR/fake-editor" issue open
  Moving /tmp/*/issue/*.md to /tmp/*/issue/open/fake_test.md (glob)
  Issue saved at: /tmp/*/issue/open/fake_test.md (glob)

  $ issue list
  issue/open/fake_test.md

  $ issue status
  open\t1 (esc)

  $ issue html | grep -F '<article>'
          <article><a class='issue-bookmark' id='Fake test' href='#Fake test'>\xf0\x9f\x94\x96 open/fake_test.md</a><h1 id="fake-test">Fake test</h1> (esc)

  $ issue
  ISSUE(1)                         Issue Manual                         ISSUE(1)
  
  
  
  N\x08NA\x08AM\x08ME\x08E (esc)
         issue - Issue management from the CLI
  
  S\x08SY\x08YN\x08NO\x08OP\x08PS\x08SI\x08IS\x08S (esc)
         i\x08is\x08ss\x08su\x08ue\x08e [_\x08C_\x08O_\x08M_\x08M_\x08A_\x08N_\x08D] \xe2\x80\xa6 (esc)
  
  C\x08CO\x08OM\x08MM\x08MA\x08AN\x08ND\x08DS\x08S (esc)
         d\x08di\x08ir\x08r [_\x08O_\x08P_\x08T_\x08I_\x08O_\x08N]\xe2\x80\xa6 (esc)
             Show the current issue directory
  
         h\x08ht\x08tm\x08ml\x08l [_\x08O_\x08P_\x08T_\x08I_\x08O_\x08N]\xe2\x80\xa6 (esc)
             Print issues as HTML
  
         i\x08in\x08ni\x08it\x08t [_\x08O_\x08P_\x08T_\x08I_\x08O_\x08N]\xe2\x80\xa6 (esc)
             Create the issue directory if it doesn't exist
  
         l\x08li\x08is\x08st\x08t [_\x08O_\x08P_\x08T_\x08I_\x08O_\x08N]\xe2\x80\xa6 (esc)
             List the current issues
  
         o\x08op\x08pe\x08en\x08n [_\x08O_\x08P_\x08T_\x08I_\x08O_\x08N]\xe2\x80\xa6 (esc)
             Open a new issue
  
         s\x08se\x08ea\x08ar\x08rc\x08ch\x08h [_\x08O_\x08P_\x08T_\x08I_\x08O_\x08N]\xe2\x80\xa6 (esc)
             Keyword search through issues
  
         s\x08st\x08ta\x08at\x08tu\x08us\x08s [_\x08O_\x08P_\x08T_\x08I_\x08O_\x08N]\xe2\x80\xa6 (esc)
             Show the number of files in each issue category
  
  C\x08CO\x08OM\x08MM\x08MO\x08ON\x08N O\x08OP\x08PT\x08TI\x08IO\x08ON\x08NS\x08S (esc)
         -\x08--\x08-h\x08he\x08el\x08lp\x08p[=_\x08F_\x08M_\x08T] (default=a\x08au\x08ut\x08to\x08o) (esc)
             Show this help in format _\x08F_\x08M_\x08T. The value _\x08F_\x08M_\x08T must be one of a\x08au\x08ut\x08to\x08o, (esc)
             p\x08pa\x08ag\x08ge\x08er\x08r, g\x08gr\x08ro\x08of\x08ff\x08f or p\x08pl\x08la\x08ai\x08in\x08n. With a\x08au\x08ut\x08to\x08o, the format is p\x08pa\x08ag\x08ge\x08er\x08r or p\x08pl\x08la\x08ai\x08in\x08n (esc)
             whenever the T\x08TE\x08ER\x08RM\x08M env var is d\x08du\x08um\x08mb\x08b or undefined. (esc)
  
         -\x08--\x08-v\x08ve\x08er\x08rs\x08si\x08io\x08on\x08n (esc)
             Show version information.
  
  E\x08EX\x08XI\x08IT\x08T S\x08ST\x08TA\x08AT\x08TU\x08US\x08S (esc)
         i\x08is\x08ss\x08su\x08ue\x08e exits with: (esc)
  
         0   on success.
  
         123 on indiscriminate errors reported on standard error.
  
         124 on command line parsing errors.
  
         125 on unexpected internal errors (bugs).
  
  B\x08BU\x08UG\x08GS\x08S (esc)
         Email bug reports to <bassimhuis@gmail.com>.
  
  
  
  Issue 11VERSION11                                                     ISSUE(1)






















