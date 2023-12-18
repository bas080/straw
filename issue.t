#!/usr/bin/env cram

  $ cd $TESTDIR/browser
  > {
  >   npm ci
  >   npm run lint
  >   npm run build
  >   npm t
  > } &> /dev/null

  $ cd $TESTDIR

  $ dune build
  $ dune install

  $ cd $CRAMTMP

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
  open/fake_test.md

  $ issue status
  open\t1 (esc)

  $ issue html
  <!doctype html>
  <html lang="en">
    <head>
      <title>Issue / Issues</title>
  
      <link
        rel="icon"
        href="data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 100 100%22><text y=%22.9em%22 font-size=%2290%22>\xf0\x9f\xaa\xa3</text></svg>" (esc)
      />
      <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  
      <!-- simplecss -->
      <style>
        ::backdrop,
        :root {
          --sans-font: -apple-system, BlinkMacSystemFont, "Avenir Next", Avenir,
            "Nimbus Sans L", Roboto, "Noto Sans", "Segoe UI", Arial, Helvetica,
            "Helvetica Neue", sans-serif;
          --mono-font: Consolas, Menlo, Monaco, "Andale Mono", "Ubuntu Mono",
            monospace;
          --standard-border-radius: 5px;
          --bg: #fff;
          --accent-bg: #f5f7ff;
          --text: #212121;
          --text-light: #585858;
          --border: #898ea4;
          --accent: #0d47a1;
          --code: #d81b60;
          --preformatted: #444;
          --marked: #ffdd33;
          --disabled: #efefef;
        }
        @media (prefers-color-scheme: dark) {
          ::backdrop,
          :root {
            color-scheme: dark;
            --bg: #212121;
            --accent-bg: #2b2b2b;
            --text: #dcdcdc;
            --text-light: #ababab;
            --accent: #ffb300;
            --code: #f06292;
            --preformatted: #ccc;
            --disabled: #111;
          }
          img,
          video {
            opacity: 0.8;
          }
        }
        *,
        ::after,
        ::before {
          box-sizing: border-box;
        }
        input,
        progress,
        select,
        textarea {
          appearance: none;
          -webkit-appearance: none;
          -moz-appearance: none;
        }
        html {
          font-family: var(--sans-font);
          scroll-behavior: smooth;
        }
        body {
          color: var(--text);
          background-color: var(--bg);
          font-size: 1.15rem;
          line-height: 1.5;
          display: grid;
          grid-template-columns: 1fr min(45rem, 90%) 1fr;
          margin: 0;
        }
        body > * {
          grid-column: 2;
        }
        body > header {
          background-color: var(--accent-bg);
          border-bottom: 1px solid var(--border);
          text-align: center;
          padding: 0 0.5rem 2rem 0.5rem;
          grid-column: 1/-1;
        }
        body > header > :only-child {
          margin-block-start: 2rem;
        }
        body > header h1 {
          max-width: 1200px;
          margin: 1rem auto;
        }
        body > header p {
          max-width: 40rem;
          margin: 1rem auto;
        }
        main {
          padding-top: 1.5rem;
        }
        body > footer {
          margin-top: 4rem;
          padding: 2rem 1rem 1.5rem 1rem;
          color: var(--text-light);
          font-size: 0.9rem;
          text-align: center;
          border-top: 1px solid var(--border);
        }
        h1 {
          font-size: 3rem;
        }
        h2 {
          font-size: 2.6rem;
          margin-top: 3rem;
        }
        h3 {
          font-size: 2rem;
          margin-top: 3rem;
        }
        h4 {
          font-size: 1.44rem;
        }
        h5 {
          font-size: 1.15rem;
        }
        h6 {
          font-size: 0.96rem;
        }
        p {
          margin: 1.5rem 0;
        }
        h1,
        h2,
        h3,
        h4,
        h5,
        h6,
        p {
          overflow-wrap: break-word;
        }
        h1,
        h2,
        h3 {
          line-height: 1.1;
        }
        @media only screen and (max-width: 720px) {
          h1 {
            font-size: 2.5rem;
          }
          h2 {
            font-size: 2.1rem;
          }
          h3 {
            font-size: 1.75rem;
          }
          h4 {
            font-size: 1.25rem;
          }
        }
        a,
        a:visited {
          color: var(--accent);
        }
        a:hover {
          text-decoration: none;
        }
        .button,
        a.button,
        button,
        input[type="button"],
        input[type="reset"],
        input[type="submit"],
        label[type="button"] {
          border: 1px solid var(--accent);
          background-color: var(--accent);
          color: var(--bg);
          padding: 0.5rem 0.9rem;
          text-decoration: none;
          line-height: normal;
        }
        .button[aria-disabled="true"],
        button[disabled],
        input:disabled,
        select:disabled,
        textarea:disabled {
          cursor: not-allowed;
          background-color: var(--disabled);
          border-color: var(--disabled);
          color: var(--text-light);
        }
        input[type="range"] {
          padding: 0;
        }
        abbr[title] {
          cursor: help;
          text-decoration-line: underline;
          text-decoration-style: dotted;
        }
        .button:not([aria-disabled="true"]):hover,
        button:enabled:hover,
        input[type="button"]:enabled:hover,
        input[type="reset"]:enabled:hover,
        input[type="submit"]:enabled:hover,
        label[type="button"]:hover {
          filter: brightness(1.4);
          cursor: pointer;
        }
        .button:focus-visible,
        button:focus-visible:where(:enabled),
        input:enabled:focus-visible:where(
            [type="submit"],
            [type="reset"],
            [type="button"]
          ) {
          outline: 2px solid var(--accent);
          outline-offset: 1px;
        }
        header > nav {
          font-size: 1rem;
          line-height: 2;
          padding: 1rem 0 0 0;
        }
        header > nav ol,
        header > nav ul {
          align-content: space-around;
          align-items: center;
          display: flex;
          flex-direction: row;
          flex-wrap: wrap;
          justify-content: center;
          list-style-type: none;
          margin: 0;
          padding: 0;
        }
        header > nav ol li,
        header > nav ul li {
          display: inline-block;
        }
        header > nav a,
        header > nav a:visited {
          margin: 0 0.5rem 1rem 0.5rem;
          border: 1px solid var(--border);
          border-radius: var(--standard-border-radius);
          color: var(--text);
          display: inline-block;
          padding: 0.1rem 1rem;
          text-decoration: none;
        }
        header > nav a.current,
        header > nav a:hover,
        header > nav a[aria-current="page"] {
          border-color: var(--accent);
          color: var(--accent);
          cursor: pointer;
        }
        @media only screen and (max-width: 720px) {
          header > nav a {
            border: none;
            padding: 0;
            text-decoration: underline;
            line-height: 1;
          }
        }
        aside,
        details,
        pre,
        progress {
          background-color: var(--accent-bg);
          border: 1px solid var(--border);
          border-radius: var(--standard-border-radius);
          margin-bottom: 1rem;
        }
        aside {
          font-size: 1rem;
          width: 30%;
          padding: 0 15px;
          margin-inline-start: 15px;
          float: right;
        }
        [dir="rtl"] aside {
          float: left;
        }
        @media only screen and (max-width: 720px) {
          aside {
            width: 100%;
            float: none;
            margin-inline-start: 0;
          }
        }
        article,
        dialog,
        fieldset {
          border: 1px solid var(--border);
          padding: 1rem;
          border-radius: var(--standard-border-radius);
          margin-bottom: 1rem;
        }
        article h2:first-child,
        section h2:first-child {
          margin-top: 1rem;
        }
        section {
          border-top: 1px solid var(--border);
          border-bottom: 1px solid var(--border);
          padding: 2rem 1rem;
          margin: 3rem 0;
        }
        section + section,
        section:first-child {
          border-top: 0;
          padding-top: 0;
        }
        section:last-child {
          border-bottom: 0;
          padding-bottom: 0;
        }
        details {
          padding: 0.7rem 1rem;
        }
        summary {
          cursor: pointer;
          font-weight: 700;
          padding: 0.7rem 1rem;
          margin: -0.7rem -1rem;
          word-break: break-all;
        }
        details[open] > summary + * {
          margin-top: 0;
        }
        details[open] > summary {
          margin-bottom: 0.5rem;
        }
        details[open] > :last-child {
          margin-bottom: 0;
        }
        table {
          border-collapse: collapse;
          margin: 1.5rem 0;
        }
        td,
        th {
          border: 1px solid var(--border);
          text-align: start;
          padding: 0.5rem;
        }
        th {
          background-color: var(--accent-bg);
          font-weight: 700;
        }
        tr:nth-child(even) {
          background-color: var(--accent-bg);
        }
        table caption {
          font-weight: 700;
          margin-bottom: 0.5rem;
        }
        .button,
        button,
        input,
        select,
        textarea {
          font-size: inherit;
          font-family: inherit;
          padding: 0.5rem;
          margin-bottom: 0.5rem;
          border-radius: var(--standard-border-radius);
          box-shadow: none;
          max-width: 100%;
          display: inline-block;
        }
        input,
        select,
        textarea {
          color: var(--text);
          background-color: var(--bg);
          border: 1px solid var(--border);
        }
        label {
          display: block;
        }
        textarea:not([cols]) {
          width: 100%;
        }
        select:not([multiple]) {
          background-image: linear-gradient(
              45deg,
              transparent 49%,
              var(--text) 51%
            ),
            linear-gradient(135deg, var(--text) 51%, transparent 49%);
          background-position: calc(100% - 15px), calc(100% - 10px);
          background-size:
            5px 5px,
            5px 5px;
          background-repeat: no-repeat;
          padding-inline-end: 25px;
        }
        [dir="rtl"] select:not([multiple]) {
          background-position: 10px, 15px;
        }
        input[type="checkbox"],
        input[type="radio"] {
          vertical-align: middle;
          position: relative;
          width: min-content;
        }
        input[type="checkbox"] + label,
        input[type="radio"] + label {
          display: inline-block;
        }
        input[type="radio"] {
          border-radius: 100%;
        }
        input[type="checkbox"]:checked,
        input[type="radio"]:checked {
          background-color: var(--accent);
        }
        input[type="checkbox"]:checked::after {
          content: " ";
          width: 0.18em;
          height: 0.32em;
          border-radius: 0;
          position: absolute;
          top: 0.05em;
          left: 0.17em;
          background-color: transparent;
          border-right: solid var(--bg) 0.08em;
          border-bottom: solid var(--bg) 0.08em;
          font-size: 1.8em;
          transform: rotate(45deg);
        }
        input[type="radio"]:checked::after {
          content: " ";
          width: 0.25em;
          height: 0.25em;
          border-radius: 100%;
          position: absolute;
          top: 0.125em;
          background-color: var(--bg);
          left: 0.125em;
          font-size: 32px;
        }
        @media only screen and (max-width: 720px) {
          input,
          select,
          textarea {
            width: 100%;
          }
        }
        input[type="color"] {
          height: 2.5rem;
          padding: 0.2rem;
        }
        input[type="file"] {
          border: 0;
        }
        hr {
          border: none;
          height: 1px;
          background: var(--border);
          margin: 1rem auto;
        }
        mark {
          padding: 2px 5px;
          border-radius: var(--standard-border-radius);
          background-color: var(--marked);
          color: #000;
        }
        mark a {
          color: #0d47a1;
        }
        img,
        video {
          max-width: 100%;
          height: auto;
          border-radius: var(--standard-border-radius);
        }
        figure {
          margin: 0;
          display: block;
          overflow-x: auto;
        }
        figcaption {
          text-align: center;
          font-size: 0.9rem;
          color: var(--text-light);
          margin-bottom: 1rem;
        }
        blockquote {
          margin-inline-start: 2rem;
          margin-inline-end: 0;
          margin-block: 2rem;
          padding: 0.4rem 0.8rem;
          border-inline-start: 0.35rem solid var(--accent);
          color: var(--text-light);
          font-style: italic;
        }
        cite {
          font-size: 0.9rem;
          color: var(--text-light);
          font-style: normal;
        }
        dt {
          color: var(--text-light);
        }
        code,
        kbd,
        pre,
        pre span,
        samp {
          font-family: var(--mono-font);
          color: var(--code);
        }
        kbd {
          color: var(--preformatted);
          border: 1px solid var(--preformatted);
          border-bottom: 3px solid var(--preformatted);
          border-radius: var(--standard-border-radius);
          padding: 0.1rem 0.4rem;
        }
        pre {
          padding: 1rem 1.4rem;
          max-width: 100%;
          overflow: auto;
          color: var(--preformatted);
        }
        pre code {
          color: var(--preformatted);
          background: 0 0;
          margin: 0;
          padding: 0;
        }
        progress {
          width: 100%;
        }
        progress:indeterminate {
          background-color: var(--accent-bg);
        }
        progress::-webkit-progress-bar {
          border-radius: var(--standard-border-radius);
          background-color: var(--accent-bg);
        }
        progress::-webkit-progress-value {
          border-radius: var(--standard-border-radius);
          background-color: var(--accent);
        }
        progress::-moz-progress-bar {
          border-radius: var(--standard-border-radius);
          background-color: var(--accent);
          transition-property: width;
          transition-duration: 0.3s;
        }
        progress:indeterminate::-moz-progress-bar {
          background-color: var(--accent-bg);
        }
        dialog {
          max-width: 40rem;
          margin: auto;
        }
        dialog::backdrop {
          background-color: var(--bg);
          opacity: 0.8;
        }
        @media only screen and (max-width: 720px) {
          dialog {
            max-width: 100%;
            margin: auto 1em;
          }
        }
        sub,
        sup {
          vertical-align: baseline;
          position: relative;
        }
        sup {
          top: -0.4em;
        }
        sub {
          top: 0.3em;
        }
        .notice {
          background: var(--accent-bg);
          border: 2px solid var(--border);
          border-radius: 5px;
          padding: 1.5rem;
          margin: 2rem 0;
        }
      </style>
    </head>
  
    <body>
      <main>
        <label for="issue-search-input">Filter</label>
        <div id="issue-search">
          <p>
            <noscript>
              Please enable JavaScript for the filter function:
              <a href="https://www.enable-javascript.com/">
                How to enable JavaScript.
              </a>
              <hr />
            </noscript>
            Loading...
          </p>
        </div>
  
        <details>
          <summary>Filter Cheatsheet</summary>
          <dl>
            <dt><code>term</code></dt>
            <dd>Matches a case-sensitive substring.</dd>
  
            <dt><code>"two terms"</code></dt>
            <dd>Allows querying with spaces by using a quoted string.</dd>
  
            <dt><code>/directory</code></dt>
            <dd>
              Filters issues that belong to a specific directory or iteration.
            </dd>
  
            <dt><code>#hashtag</code></dt>
            <dd>Identifies issues that include a specific hashtag.</dd>
  
            <dt><code>@mention</code></dt>
            <dd>Finds issues that mention a specific person.</dd>
  
            <dt><code>or</code></dt>
            <dd>
              Introduces a logical OR operator to stop the previous query and
              define another one for finding more issues.
            </dd>
          </dl>
        </details>
        <p id="issue-search-count"></p>
  
        <div class="issue-issues">
          <article><a class='issue-bookmark' id='Fake test' href='#Fake test'>\xf0\x9f\x94\x96 open/fake_test.md</a><h1 id="fake-test">Fake test</h1> (esc)
  <p>Some body</p>
  </article>
  
        </div>
      </main>
  
      <footer>
        <p>
          <span>Powered by </span>
          <a href="https://simplecss.org/">simplecss.org</a>
          \xc2\xb7 <a href="https://lit.dev/">lit.dev</a> \xc2\xb7 (esc)
          <a href="https://ocaml.org/">ocaml.org</a> \xc2\xb7 (esc)
          <a href="https://esbuild.github.io/">esbuild</a> \xc2\xb7 (esc)
          <a href="https://github.com/mahhov/inline-scripts">inline-scripts</a>
          <span title="Heart"> \xf0\x9f\xab\x80</span> (esc)
        </p>
  
        <p>
          <span>Developers </span>
          <a href="https://bas080.github.io/">Bas Huis</a>
          \xc2\xb7 <a href="https://github.com/antoniskalou">Antonis Kalou</a> (esc)
        </p>
      </footer>
    </body>
  
    <style>
      label {
        font-size: 1.2em;
        opacity: 0.8;
      }
  
      article {
        overflow: hidden;
      }
  
      #issue-search {
        border: 1px solid var(--border);
        border-radius: var(--standard-border-radius);
        background-color: var(--accent-bg);
        padding: min(1em, 4vw);
        margin: 1em 0;
      }
  
      #issue-search ul {
        margin: min(1em, 4vw) 0 0 0;
      }
  
      .issue-bookmark {
        word-break: break-all;
      }
  
      .badge {
        font-size: 0.8em;
        padding: 0 0.5ex;
        border-radius: 0.5em;
      }
  
      .badge-primary {
        background-color: var(--bg);
        border: 1px solid var(--border);
      }
  
      .issue-search-query-items {
        list-style-type: none;
        padding-left: 0;
      }
  
      .issue-search-query-items li {
        display: inline-block;
        margin-right: 1em;
      }
  
      .issue-search-query-item {
        display: inline-block;
        border: 1px solid var(--border);
        padding-left: 1ex;
        padding-right: 1ex;
        border-radius: 1ex;
        background-color: var(--bg);
        color: var(--text);
      }
  
      .issue-search-query-or-item {
        width: 100%;
        margin-bottom: 0.5rem;
        margin-left: 0;
        text-align: center;
      }
  
      .issue-search-mention,
      .issue-search-directory,
      .issue-search-hashtag {
        color: var(--code);
      }
  
      .issue-issues {
        display: flex;
        flex-flow: column;
      }
  
      .issue-issues > article {
        opacity: 1;
        order: 1;
        transition: opacity 0.5s ease;
      }
  
      .issue-issues > article.disabled {
        opacity: 0.1;
        pointer-events: none;
        order: 2;
      }
  
      .issue-hash {
        color: var(--code);
        font-weight: bold;
      }
  
      .issue-hash {
      }
  
      details {
        opacity: 0.5;
      }
  
      details summary {
        font-weight: normal;
      }
  
      details:focus-within,
      details:focus {
        opacity: 1;
      }
  
      #issue-search-input {
        width: 100%;
      }
  
      .issue-suggestion {
        background: none;
        color: var(--accent);
        border: none;
        text-decoration: underline;
      }
  
      .issue-suggestion:hover {
        text-decoration: none;
      }
    </style>
  
    <script>(() => {
    // helpers.mjs
    var call = (fn, ...args) => fn(...args);
    var isNil = (x2) => x2 == null;
    var partial = (fn, ...args) => fn.bind(null, ...args);
    var isEmpty = (x2) => x2.length === 0;
    var isOdd = (x2) => x2 % 2 === 1;
    var excludeIndex = (index, array) => {
      const result = Array.prototype.slice.call(array, 0);
      result.splice(index, 1);
      return result;
    };
    var identity = (x2) => x2;
    var equals = (a2, b2) => a2 === b2;
    var intersection = (xs, ys, equal = equals) => xs.filter((x2) => ys.some((y2) => equal(x2, y2)));
    var complement = (fn) => (...args) => !fn(...args);
    var indexSplit = (i3, str) => [str.substring(0, i3), str.substring(i3)];
    var butLast = (arr) => arr.slice(0, -1);
    var last = (arr) => arr[arr.length - 1];
    var notEquals = complement(equals);
    var isNotEmpty = complement(isEmpty);
    var byKey = (object, defaultTo) => (key) => object[key] || defaultTo;
    var uniq = (arr) => [...new Set(arr)];
    var isNotNil = complement(isNil);
  
    // node_modules/lit-html/lit-html.js
    var t = globalThis;
    var i = t.trustedTypes;
    var s = i ? i.createPolicy("lit-html", { createHTML: (t4) => t4 }) : void 0;
    var e = "$lit$";
    var h = `lit$${(Math.random() + "").slice(9)}$`;
    var o = "?" + h;
    var n = `<${o}>`;
    var r = document;
    var l = () => r.createComment("");
    var c = (t4) => null === t4 || "object" != typeof t4 && "function" != typeof t4;
    var a = Array.isArray;
    var u = (t4) => a(t4) || "function" == typeof t4?.[Symbol.iterator];
    var d = "[ \t\\n\\f\\r]"; (esc)
    var f = /<(?:(!--|\/[^a-zA-Z])|(\/?[a-zA-Z][^>\s]*)|(\/?$))/g;
    var v = /-->/g;
    var _ = />/g;
    var m = RegExp(`>|${d}(?:([^\\\\s"'>=/]+)(${d}*=${d}*(?:[^ \t (esc)
  \f\r"'\`<>=]|("|')|))|$)`, "g");
    var p = /'/g;
    var g = /"/g;
    var $ = /^(?:script|style|textarea|title)$/i;
    var y = (t4) => (i3, ...s3) => ({ _$litType$: t4, strings: i3, values: s3 });
    var x = y(1);
    var b = y(2);
    var w = Symbol.for("lit-noChange");
    var T = Symbol.for("lit-nothing");
    var A = /* @__PURE__ */ new WeakMap();
    var E = r.createTreeWalker(r, 129);
    function C(t4, i3) {
      if (!Array.isArray(t4) || !t4.hasOwnProperty("raw"))
        throw Error("invalid template strings array");
      return void 0 !== s ? s.createHTML(i3) : i3;
    }
    var P = (t4, i3) => {
      const s3 = t4.length - 1, o4 = [];
      let r3, l2 = 2 === i3 ? "<svg>" : "", c3 = f;
      for (let i4 = 0; i4 < s3; i4++) {
        const s4 = t4[i4];
        let a2, u2, d2 = -1, y2 = 0;
        for (; y2 < s4.length && (c3.lastIndex = y2, u2 = c3.exec(s4), null !== u2); )
          y2 = c3.lastIndex, c3 === f ? "!--" === u2[1] ? c3 = v : void 0 !== u2[1] ? c3 = _ : void 0 !== u2[2] ? ($.test(u2[2]) && (r3 = RegExp("</" + u2[2], "g")), c3 = m) : void 0 !== u2[3] && (c3 = m) : c3 === m ? ">" === u2[0] ? (c3 = r3 ?? f, d2 = -1) : void 0 === u2[1] ? d2 = -2 : (d2 = c3.lastIndex - u2[2].length, a2 = u2[1], c3 = void 0 === u2[3] ? m : '"' === u2[3] ? g : p) : c3 === g || c3 === p ? c3 = m : c3 === v || c3 === _ ? c3 = f : (c3 = m, r3 = void 0);
        const x2 = c3 === m && t4[i4 + 1].startsWith("/>") ? " " : "";
        l2 += c3 === f ? s4 + n : d2 >= 0 ? (o4.push(a2), s4.slice(0, d2) + e + s4.slice(d2) + h + x2) : s4 + h + (-2 === d2 ? i4 : x2);
      }
      return [C(t4, l2 + (t4[s3] || "<?>") + (2 === i3 ? "</svg>" : "")), o4];
    };
    var V = class _V {
      constructor({ strings: t4, _$litType$: s3 }, n4) {
        let r3;
        this.parts = [];
        let c3 = 0, a2 = 0;
        const u2 = t4.length - 1, d2 = this.parts, [f4, v2] = P(t4, s3);
        if (this.el = _V.createElement(f4, n4), E.currentNode = this.el.content, 2 === s3) {
          const t5 = this.el.content.firstChild;
          t5.replaceWith(...t5.childNodes);
        }
        for (; null !== (r3 = E.nextNode()) && d2.length < u2; ) {
          if (1 === r3.nodeType) {
            if (r3.hasAttributes())
              for (const t5 of r3.getAttributeNames())
                if (t5.endsWith(e)) {
                  const i3 = v2[a2++], s4 = r3.getAttribute(t5).split(h), e4 = /([.?@])?(.*)/.exec(i3);
                  d2.push({ type: 1, index: c3, name: e4[2], strings: s4, ctor: "." === e4[1] ? k : "?" === e4[1] ? H : "@" === e4[1] ? I : R }), r3.removeAttribute(t5);
                } else
                  t5.startsWith(h) && (d2.push({ type: 6, index: c3 }), r3.removeAttribute(t5));
            if ($.test(r3.tagName)) {
              const t5 = r3.textContent.split(h), s4 = t5.length - 1;
              if (s4 > 0) {
                r3.textContent = i ? i.emptyScript : "";
                for (let i3 = 0; i3 < s4; i3++)
                  r3.append(t5[i3], l()), E.nextNode(), d2.push({ type: 2, index: ++c3 });
                r3.append(t5[s4], l());
              }
            }
          } else if (8 === r3.nodeType)
            if (r3.data === o)
              d2.push({ type: 2, index: c3 });
            else {
              let t5 = -1;
              for (; -1 !== (t5 = r3.data.indexOf(h, t5 + 1)); )
                d2.push({ type: 7, index: c3 }), t5 += h.length - 1;
            }
          c3++;
        }
      }
      static createElement(t4, i3) {
        const s3 = r.createElement("template");
        return s3.innerHTML = t4, s3;
      }
    };
    function N(t4, i3, s3 = t4, e4) {
      if (i3 === w)
        return i3;
      let h4 = void 0 !== e4 ? s3._$Co?.[e4] : s3._$Cl;
      const o4 = c(i3) ? void 0 : i3._$litDirective$;
      return h4?.constructor !== o4 && (h4?._$AO?.(false), void 0 === o4 ? h4 = void 0 : (h4 = new o4(t4), h4._$AT(t4, s3, e4)), void 0 !== e4 ? (s3._$Co ??= [])[e4] = h4 : s3._$Cl = h4), void 0 !== h4 && (i3 = N(t4, h4._$AS(t4, i3.values), h4, e4)), i3;
    }
    var S = class {
      constructor(t4, i3) {
        this._$AV = [], this._$AN = void 0, this._$AD = t4, this._$AM = i3;
      }
      get parentNode() {
        return this._$AM.parentNode;
      }
      get _$AU() {
        return this._$AM._$AU;
      }
      u(t4) {
        const { el: { content: i3 }, parts: s3 } = this._$AD, e4 = (t4?.creationScope ?? r).importNode(i3, true);
        E.currentNode = e4;
        let h4 = E.nextNode(), o4 = 0, n4 = 0, l2 = s3[0];
        for (; void 0 !== l2; ) {
          if (o4 === l2.index) {
            let i4;
            2 === l2.type ? i4 = new M(h4, h4.nextSibling, this, t4) : 1 === l2.type ? i4 = new l2.ctor(h4, l2.name, l2.strings, this, t4) : 6 === l2.type && (i4 = new L(h4, this, t4)), this._$AV.push(i4), l2 = s3[++n4];
          }
          o4 !== l2?.index && (h4 = E.nextNode(), o4++);
        }
        return E.currentNode = r, e4;
      }
      p(t4) {
        let i3 = 0;
        for (const s3 of this._$AV)
          void 0 !== s3 && (void 0 !== s3.strings ? (s3._$AI(t4, s3, i3), i3 += s3.strings.length - 2) : s3._$AI(t4[i3])), i3++;
      }
    };
    var M = class _M {
      get _$AU() {
        return this._$AM?._$AU ?? this._$Cv;
      }
      constructor(t4, i3, s3, e4) {
        this.type = 2, this._$AH = T, this._$AN = void 0, this._$AA = t4, this._$AB = i3, this._$AM = s3, this.options = e4, this._$Cv = e4?.isConnected ?? true;
      }
      get parentNode() {
        let t4 = this._$AA.parentNode;
        const i3 = this._$AM;
        return void 0 !== i3 && 11 === t4?.nodeType && (t4 = i3.parentNode), t4;
      }
      get startNode() {
        return this._$AA;
      }
      get endNode() {
        return this._$AB;
      }
      _$AI(t4, i3 = this) {
        t4 = N(this, t4, i3), c(t4) ? t4 === T || null == t4 || "" === t4 ? (this._$AH !== T && this._$AR(), this._$AH = T) : t4 !== this._$AH && t4 !== w && this._(t4) : void 0 !== t4._$litType$ ? this.g(t4) : void 0 !== t4.nodeType ? this.$(t4) : u(t4) ? this.T(t4) : this._(t4);
      }
      k(t4) {
        return this._$AA.parentNode.insertBefore(t4, this._$AB);
      }
      $(t4) {
        this._$AH !== t4 && (this._$AR(), this._$AH = this.k(t4));
      }
      _(t4) {
        this._$AH !== T && c(this._$AH) ? this._$AA.nextSibling.data = t4 : this.$(r.createTextNode(t4)), this._$AH = t4;
      }
      g(t4) {
        const { values: i3, _$litType$: s3 } = t4, e4 = "number" == typeof s3 ? this._$AC(t4) : (void 0 === s3.el && (s3.el = V.createElement(C(s3.h, s3.h[0]), this.options)), s3);
        if (this._$AH?._$AD === e4)
          this._$AH.p(i3);
        else {
          const t5 = new S(e4, this), s4 = t5.u(this.options);
          t5.p(i3), this.$(s4), this._$AH = t5;
        }
      }
      _$AC(t4) {
        let i3 = A.get(t4.strings);
        return void 0 === i3 && A.set(t4.strings, i3 = new V(t4)), i3;
      }
      T(t4) {
        a(this._$AH) || (this._$AH = [], this._$AR());
        const i3 = this._$AH;
        let s3, e4 = 0;
        for (const h4 of t4)
          e4 === i3.length ? i3.push(s3 = new _M(this.k(l()), this.k(l()), this, this.options)) : s3 = i3[e4], s3._$AI(h4), e4++;
        e4 < i3.length && (this._$AR(s3 && s3._$AB.nextSibling, e4), i3.length = e4);
      }
      _$AR(t4 = this._$AA.nextSibling, i3) {
        for (this._$AP?.(false, true, i3); t4 && t4 !== this._$AB; ) {
          const i4 = t4.nextSibling;
          t4.remove(), t4 = i4;
        }
      }
      setConnected(t4) {
        void 0 === this._$AM && (this._$Cv = t4, this._$AP?.(t4));
      }
    };
    var R = class {
      get tagName() {
        return this.element.tagName;
      }
      get _$AU() {
        return this._$AM._$AU;
      }
      constructor(t4, i3, s3, e4, h4) {
        this.type = 1, this._$AH = T, this._$AN = void 0, this.element = t4, this.name = i3, this._$AM = e4, this.options = h4, s3.length > 2 || "" !== s3[0] || "" !== s3[1] ? (this._$AH = Array(s3.length - 1).fill(new String()), this.strings = s3) : this._$AH = T;
      }
      _$AI(t4, i3 = this, s3, e4) {
        const h4 = this.strings;
        let o4 = false;
        if (void 0 === h4)
          t4 = N(this, t4, i3, 0), o4 = !c(t4) || t4 !== this._$AH && t4 !== w, o4 && (this._$AH = t4);
        else {
          const e5 = t4;
          let n4, r3;
          for (t4 = h4[0], n4 = 0; n4 < h4.length - 1; n4++)
            r3 = N(this, e5[s3 + n4], i3, n4), r3 === w && (r3 = this._$AH[n4]), o4 ||= !c(r3) || r3 !== this._$AH[n4], r3 === T ? t4 = T : t4 !== T && (t4 += (r3 ?? "") + h4[n4 + 1]), this._$AH[n4] = r3;
        }
        o4 && !e4 && this.O(t4);
      }
      O(t4) {
        t4 === T ? this.element.removeAttribute(this.name) : this.element.setAttribute(this.name, t4 ?? "");
      }
    };
    var k = class extends R {
      constructor() {
        super(...arguments), this.type = 3;
      }
      O(t4) {
        this.element[this.name] = t4 === T ? void 0 : t4;
      }
    };
    var H = class extends R {
      constructor() {
        super(...arguments), this.type = 4;
      }
      O(t4) {
        this.element.toggleAttribute(this.name, !!t4 && t4 !== T);
      }
    };
    var I = class extends R {
      constructor(t4, i3, s3, e4, h4) {
        super(t4, i3, s3, e4, h4), this.type = 5;
      }
      _$AI(t4, i3 = this) {
        if ((t4 = N(this, t4, i3, 0) ?? T) === w)
          return;
        const s3 = this._$AH, e4 = t4 === T && s3 !== T || t4.capture !== s3.capture || t4.once !== s3.once || t4.passive !== s3.passive, h4 = t4 !== T && (s3 === T || e4);
        e4 && this.element.removeEventListener(this.name, this, s3), h4 && this.element.addEventListener(this.name, this, t4), this._$AH = t4;
      }
      handleEvent(t4) {
        "function" == typeof this._$AH ? this._$AH.call(this.options?.host ?? this.element, t4) : this._$AH.handleEvent(t4);
      }
    };
    var L = class {
      constructor(t4, i3, s3) {
        this.element = t4, this.type = 6, this._$AN = void 0, this._$AM = i3, this.options = s3;
      }
      get _$AU() {
        return this._$AM._$AU;
      }
      _$AI(t4) {
        N(this, t4);
      }
    };
    var z = { j: e, P: h, A: o, C: 1, M: P, L: S, R: u, V: N, D: M, I: R, H, N: I, U: k, B: L };
    var Z = t.litHtmlPolyfillSupport;
    Z?.(V, M), (t.litHtmlVersions ??= []).push("3.1.0");
    var j = (t4, i3, s3) => {
      const e4 = s3?.renderBefore ?? i3;
      let h4 = e4._$litPart$;
      if (void 0 === h4) {
        const t5 = s3?.renderBefore ?? null;
        e4._$litPart$ = h4 = new M(i3.insertBefore(l(), t5), t5, void 0, s3 ?? {});
      }
      return h4._$AI(t4), h4;
    };
  
    // node_modules/lit-html/directive-helpers.js
    var { D: t2 } = z;
    var f2 = (o4) => void 0 === o4.strings;
  
    // node_modules/lit-html/directive.js
    var t3 = { ATTRIBUTE: 1, CHILD: 2, PROPERTY: 3, BOOLEAN_ATTRIBUTE: 4, EVENT: 5, ELEMENT: 6 };
    var e2 = (t4) => (...e4) => ({ _$litDirective$: t4, values: e4 });
    var i2 = class {
      constructor(t4) {
      }
      get _$AU() {
        return this._$AM._$AU;
      }
      _$AT(t4, e4, i3) {
        this._$Ct = t4, this._$AM = e4, this._$Ci = i3;
      }
      _$AS(t4, e4) {
        return this.update(t4, e4);
      }
      update(t4, e4) {
        return this.render(...e4);
      }
    };
  
    // node_modules/lit-html/async-directive.js
    var s2 = (i3, t4) => {
      const e4 = i3._$AN;
      if (void 0 === e4)
        return false;
      for (const i4 of e4)
        i4._$AO?.(t4, false), s2(i4, t4);
      return true;
    };
    var o2 = (i3) => {
      let t4, e4;
      do {
        if (void 0 === (t4 = i3._$AM))
          break;
        e4 = t4._$AN, e4.delete(i3), i3 = t4;
      } while (0 === e4?.size);
    };
    var r2 = (i3) => {
      for (let t4; t4 = i3._$AM; i3 = t4) {
        let e4 = t4._$AN;
        if (void 0 === e4)
          t4._$AN = e4 = /* @__PURE__ */ new Set();
        else if (e4.has(i3))
          break;
        e4.add(i3), c2(t4);
      }
    };
    function h2(i3) {
      void 0 !== this._$AN ? (o2(this), this._$AM = i3, r2(this)) : this._$AM = i3;
    }
    function n2(i3, t4 = false, e4 = 0) {
      const r3 = this._$AH, h4 = this._$AN;
      if (void 0 !== h4 && 0 !== h4.size)
        if (t4)
          if (Array.isArray(r3))
            for (let i4 = e4; i4 < r3.length; i4++)
              s2(r3[i4], false), o2(r3[i4]);
          else
            null != r3 && (s2(r3, false), o2(r3));
        else
          s2(this, i3);
    }
    var c2 = (i3) => {
      i3.type == t3.CHILD && (i3._$AP ??= n2, i3._$AQ ??= h2);
    };
    var f3 = class extends i2 {
      constructor() {
        super(...arguments), this._$AN = void 0;
      }
      _$AT(i3, t4, e4) {
        super._$AT(i3, t4, e4), r2(this), this.isConnected = i3._$AU;
      }
      _$AO(i3, t4 = true) {
        i3 !== this.isConnected && (this.isConnected = i3, i3 ? this.reconnected?.() : this.disconnected?.()), t4 && (s2(this, i3), o2(this));
      }
      setValue(t4) {
        if (f2(this._$Ct))
          this._$Ct._$AI(t4, this);
        else {
          const i3 = [...this._$Ct._$AH];
          i3[this._$Ci] = t4, this._$Ct._$AI(i3, this, 0);
        }
      }
      disconnected() {
      }
      reconnected() {
      }
    };
  
    // node_modules/lit-html/directives/ref.js
    var e3 = () => new h3();
    var h3 = class {
    };
    var o3 = /* @__PURE__ */ new WeakMap();
    var n3 = e2(class extends f3 {
      render(i3) {
        return T;
      }
      update(i3, [s3]) {
        const e4 = s3 !== this.G;
        return e4 && void 0 !== this.G && this.ot(void 0), (e4 || this.rt !== this.lt) && (this.G = s3, this.ct = i3.options?.host, this.ot(this.lt = i3.element)), T;
      }
      ot(t4) {
        if ("function" == typeof this.G) {
          const i3 = this.ct ?? globalThis;
          let s3 = o3.get(i3);
          void 0 === s3 && (s3 = /* @__PURE__ */ new WeakMap(), o3.set(i3, s3)), void 0 !== s3.get(this.G) && this.G.call(this.ct, void 0), s3.set(this.G, t4), void 0 !== t4 && this.G.call(this.ct, t4);
        } else
          this.G.value = t4;
      }
      get rt() {
        return "function" == typeof this.G ? o3.get(this.ct ?? globalThis)?.get(this.G) : this.G?.value;
      }
      disconnected() {
        this.rt === this.lt && this.ot(void 0);
      }
      reconnected() {
        this.ot(this.lt);
      }
    });
  
    // search.mjs
    var quote = (str) => `"${str}"`;
    var whitespaceRegex = /\s/;
    var hasWhitespace = (str) => whitespaceRegex.test(str);
    var quoteOnWhitespace = (token) => hasWhitespace(token) ? quote(token) : token;
    var targetValue = (fn) => ({ target: { value } }, ...args) => fn(value, ...args);
    var inputRef = e3();
    var root = document.getElementById("issue-search");
    root.innerHTML = "";
    var search = (state2, push) => {
      const { specialTokens: specialTokens2, issuesPerToken, query, tokens } = state2;
      const queryInput = inputRef.value;
      const onQueryChange = (query2) => {
        push((state3) => {
          state3.query = query2;
          return state3;
        });
      };
      const onSelectionChange = ({ target }) => {
        push(identity);
      };
      const onMouseUp = (event) => {
        onSelectionChange(event);
      };
      const onKeyUp = (event) => {
        onSelectionChange(event);
      };
      const onInput = (event) => {
        targetValue(onQueryChange)(event);
      };
      const onTokenRemove = (index) => {
        onQueryChange(excludeIndex(index, state2.tokens).join(" "));
      };
      const onSuggestionClick = (token) => (_event) => {
        const [before, after] = indexSplit(queryInput.selectionStart, state2.query);
        onQueryChange([...butLast(before.split(" ")), token, after].join(" "));
        queryInput.focus();
      };
      const suggestions = call(() => {
        if (!queryInput)
          return;
        const current = last(
          indexSplit(queryInput.selectionStart, query)[0].split(" ")
        );
        const tokens2 = specialTokens2.filter((x2) => x2.startsWith(current));
        if (isEmpty(current) || tokens2.length === 1 && tokens2[0] === current) {
          return x`<p class="issue-suggestions"></p>`;
        }
        return x`<p class="issue-suggestions">
        ${tokens2.map(
          (token) => x`<button
              @click=${onSuggestionClick(token)}
              class="issue-suggestion"
            >
              ${token}
            </button>`
        )}
      </p>`;
      });
      const searchTokenItem = (token, index, tokens2) => {
        console.log(token, index, tokens2);
        const count = issuesPerToken[token] || 0;
        if (token === "or") {
          return x`<li class="issue-search-query-or-item">or</li>`;
        }
        return x`<li>
        <button
          class="issue-search-query-item"
          title="Remove ${token}"
          value="${token}"
          @click="${partial(onTokenRemove, index)}"
        >
          ${tokenIcon(token[0])} ${quoteOnWhitespace(token)}
          <span class="badge badge-primary">${count}</span>
        </button>
      </li>`;
      };
      j(
        x`
        <input
          placeholder="terms..."
          id="issue-search-input"
          ${n3(inputRef)}
          .value="${query}"
          @keyup=${onKeyUp}
          @mouseup=${onMouseUp}
          @input=${onInput}
        />
        ${suggestions}
        <ul class="issue-search-query-items">
          ${tokens.map(searchTokenItem)}
        </ul>
      `,
        root
      );
    };
    var tokenIcon = byKey(
      {
        "#": "\u{1F3F7}\uFE0F",
        "@": "\u{1F9D1}",
        '"': "\u{1F524}",
        "/": "\u{1F4C1}"
      },
      "\u{1F524}"
    );
    var search_default = search;
  
    // issues.mjs
    function mapFocusable(elem, cb) {
      for (const focusable of elem.querySelectorAll("a")) {
        cb(focusable);
      }
    }
    function issues(state2) {
      state2.issues.forEach((elem) => {
        if (state2.matchedIssueElements.includes(elem)) {
          elem.classList.remove("disabled");
          mapFocusable(elem, (focusable) => {
            focusable.removeAttribute("tabindex");
          });
        } else {
          mapFocusable(elem, (focusable) => {
            focusable.setAttribute("tabindex", "-1");
          });
          elem.classList.add("disabled");
        }
      });
      document.getElementById("issue-search-count").innerText = `Matched ${state2.matchedIssueElements.length} / ${state2.issues.length}`;
      return state2;
    }
  
    // state.mjs
    var state = (initial, onPush) => {
      let oldState;
      const push = (cb) => {
        oldState = cb(oldState);
        oldState = onPush(oldState, push);
        return oldState;
      };
      oldState = initial();
      oldState = onPush(oldState, push);
      return push;
    };
    var firstCallSymbol = Symbol("firstCall");
    var state_default = state;
  
    // index.mjs
    var issues2 = Array.from(document.querySelectorAll(".issue-issues article"));
    var issueElementsByToken = call(() => {
      const directoryTokenRegex = /\w+(?=\/)/g;
      const otherTokensRegex = /[@#]\w+/g;
      return issues2.reduce((acc, elem) => {
        const bookmark = elem.querySelector(".issue-bookmark");
        bookmark.textContent.match(directoryTokenRegex)?.forEach((token) => {
          token = `/${token}`;
          acc[token] = acc[token] || [];
          acc[token].push(elem);
        });
        elem.textContent.match(otherTokensRegex)?.forEach((token) => {
          acc[token] = acc[token] || [];
          acc[token].push(elem);
        });
        return acc;
      }, {});
    });
    var specialTokens = Object.keys(issueElementsByToken);
    var searchTokens = (query) => {
      return query.split('"').reduce((acc, value, index) => {
        if (isOdd(index))
          return [...acc, `${value}`];
        return acc.concat(value.split(" "));
      }, []).filter(isNotEmpty);
    };
    var tokenIssues = (token) => {
      return issueElementsByToken[token] || issues2.filter((issue) => issue.textContent.includes(token));
    };
    state_default(
      () => ({
        query: getQueryParam("q") || "",
        tokens: [],
        issuesPerToken: {},
        issues: issues2,
        specialTokens,
        issueElementsByToken
      }),
      (state2, push) => {
        if (state2.query)
          setQueryParam("q", state2.query);
        else
          deleteQueryParam("q");
        state2.tokens = searchTokens(state2.query);
        state2.issuesPerToken = state2.tokens.reduce((acc, token) => {
          acc[token] = tokenIssues(token).length;
          return acc;
        }, {});
        const ors = state2.tokens.reduce(
          (acc, token) => {
            if (token === "or")
              return [[], ...acc];
            acc[0].push(token);
            return acc;
          },
          [[]]
        );
        state2.matchedIssueElements = state2.query ? uniq(
          ors.flatMap((tokens) => {
            return tokens.reduce((acc, token) => {
              return isNil(acc) ? tokenIssues(token) : intersection(acc, tokenIssues(token));
            }, null) || [];
          })
        ) : issues2;
        search_default(state2, push);
        issues(state2);
        return state2;
      }
    );
    function getQueryParam(parameterName) {
      const urlParams = new URLSearchParams(window.location.search);
      return urlParams.get(parameterName);
    }
    function setQueryParam(parameterName, newValue) {
      const urlParams = new URLSearchParams(window.location.search);
      urlParams.set(parameterName, newValue);
      const newUrl = `${window.location.pathname}?${urlParams.toString()}${window.location.hash}`;
      window.history.replaceState({}, document.title, newUrl);
    }
    function deleteQueryParam(parameterName) {
      const urlParams = new URLSearchParams(window.location.search);
      urlParams.delete(parameterName);
      const newUrl = `${window.location.pathname}?${urlParams.toString()}${window.location.hash}`;
      window.history.replaceState({}, document.title, newUrl);
    }
  })();
  /*! Bundled license information:
  
  lit-html/lit-html.js:
    (**
     * @license
     * Copyright 2017 Google LLC
     * SPDX-License-Identifier: BSD-3-Clause
     *)
  
  lit-html/directive-helpers.js:
    (**
     * @license
     * Copyright 2020 Google LLC
     * SPDX-License-Identifier: BSD-3-Clause
     *)
  
  lit-html/directive.js:
    (**
     * @license
     * Copyright 2017 Google LLC
     * SPDX-License-Identifier: BSD-3-Clause
     *)
  
  lit-html/async-directive.js:
    (**
     * @license
     * Copyright 2017 Google LLC
     * SPDX-License-Identifier: BSD-3-Clause
     *)
  
  lit-html/directives/ref.js:
    (**
     * @license
     * Copyright 2020 Google LLC
     * SPDX-License-Identifier: BSD-3-Clause
     *)
  */
  </script>
  </html>


















































































































































































































































































































































































































































































































































































  $ issue --help
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
















































































































































































