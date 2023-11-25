// Simple search script

function search (inputElement) {
  const issues = Array.from(document.getElementsByClassName("issue-issue"))

  const index = issues.map(issue => [issue, issue.textContent])

  // Consider adding a better search.
  function fuzzy (text, str) {
    return text.includes(str)
  }

  console.log(issues)

  inputElement.addEventListener("input", event => {
    const { target: { value: search } } = event

    console.log("search", search)
    index.forEach(([elem, content]) => {

      console.log(elem, content[0])

      if (fuzzy(content, search)) {
        elem.classList.remove('hidden')
      } else {
        elem.classList.add("hidden")
      }
    })
  })
}

search(document.getElementById("search"))
