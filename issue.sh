#!/usr/bin/env bashionista

function parent_find ()
{
    local file="$1";
    local dir="$2";
    test -d "$dir/$file" && echo "$dir" && return 0;
    [ '/' = "$dir" ] && return 1;
    parent_find "$file" "$(dirname "$dir")"
};
ORIG_PWD="$PWD"
cd "$(parent_find issue "$PWD")/issue";
function issue_list ()
{
    {
        find ${1:-} -type f || find */${1:-} -type f || find */${1:-}* -type f || find */*${1:-}* -type f
    } 2> /dev/null
};
function issue_ls ()
{
    issue_list "$@"
};
function issue_status ()
{
    ls -1
};
function issue_markdown ()
{
    path="$1"
    id="${path//[^[:alnum:]]/_}"
    printf '\n\n <a class="bookmark" id="%s" href="#%s">🔖 %s</a> \n\n' "$id" "$id" "$path"
    cat "$1";
    # echo '<pre>'
    # cat "$1";
    # echo '</pre>'
};
# Generates a complete site based on the issues and folders.
function issue_site() {
  build_dir='../.issue'
  mkdir -p "$build_dir"

  {
    echo '
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <link rel="stylesheet" href="https://cdn.simplecss.org/simple.min.css">
    <link
      rel="icon"
      href="data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 100 100%22><text y=%22.9em%22 font-size=%2290%22>🪣</text></svg>">
    <title>Issues</title>
    <style>
      article {
        overflow: auto;
      }
      h2 + ul {
        margin: 0;
        padding: 0;
      }
      h2 + ul li {
        display: inline-block;
        padding: 0.25rem 0.5rem;
        margin: 0.25rem;
        background-color: #00000021;
        border-radius: 0.5rem;
      }
    </style>
    <main>
    <p>“Strive not to be a success, but rather to be of value.”
    <cite>–Albert Einstein</cite>
    </p>
    <input id="search" placeholder="Search..."/>
    '

    issue_list "$@" | while read -r file; do
      echo '<article class="issue">'
      issue_markdown "$file" | pandoc --base-header-level=2 -
      echo '</article>'
    done

    echo '
    <p>“One has to kill a few of one’s natural selves to let the rest grow — a very painful slaughter of innocents.”
    <cite>–Henry Sidgwick</cite>
    </p>
    </main>
    <script>
function search (inputElement) {
  const issues = Array.from(document.getElementsByClassName("issue"))

  const index = issues.map(issue => [issue, issue.textContent])

  // Consider adding a better search.
  function fuzzy (text, str) {
    return text.includes(str)
  }

  inputElement.addEventListener("input", event => {
    const { target: { value: search } } = event

    console.log("search", search)
    let showing = 0
    index.forEach(([elem, content]) => {
      if ((search.trim() === "") || fuzzy(content, search)) {
        showing++
        elem.style.display = "block"
      } else {
        elem.style.display = "none"
      }
    })
    console.log(`Results: ${showing}/${index.length}`)
  })
}

search(document.getElementById("search"))
</script>
    '
  } | tee "$build_dir/index.html"

}
function issue_html ()
{
    issue_list "$@" | xargs -l issue markdown | pandoc -
};
function issue_show ()
{
    issue_list "$@" | parallel -k -d '\n' issue html | elinks --dump --dump-color-mode 1 | less -R
};
function issue_edit ()
{
    $EDITOR $(issue_ls "$@")
}
function issue_init ()
{
    mkdir -p "$ORIG_PWD/issue/open"
}
function issue_pwd ()
{
  pwd
}
function issue_open ()
{
    mkdir -p open
    # Test if title is defined
    test -n "$*" || {
      echo -e 'Please provide a title:\n$ issue open ...<word>'
      exit 1
    }
    local filename="$(tr '[:upper:]' '[:lower:]' <<< "$*" | tr -s ' ' '_').md"

    printf '# %s' "$*" > "open/$filename"

    $EDITOR "open/$filename"
}
function issue_grep ()
{
  cd ./issue
  grep -ri "$@"
}
