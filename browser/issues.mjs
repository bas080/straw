function mapFocusable (elem, cb) {
  for (const focusable of elem.querySelectorAll('a')) {
    cb(focusable)
  }
}

export default function issues (state) {
  state.issues.forEach((elem) => {
    if (state.matchedIssueElements.includes(elem)) {
      elem.classList.remove('disabled')
      mapFocusable(elem, (focusable) => {
        focusable.removeAttribute('tabindex')
      })
    } else {
      mapFocusable(elem, (focusable) => {
        focusable.setAttribute('tabindex', '-1')
      })
      elem.classList.add('disabled')
    }
  })

  document.getElementById('straw-search-count').innerText =
    `Matched ${state.matchedIssueElements.length} / ${state.issues.length}`

  return state
}
