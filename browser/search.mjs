import { html, render } from 'lit-html'
import { createRef, ref } from 'lit-html/directives/ref.js'
import {
  identity,
  call,
  isEmpty,
  indexSplit,
  butLast,
  last,
  byKey,
  excludeIndex,
  partial
} from './helpers.mjs'

const quote = (str) => `"${str}"`
const whitespaceRegex = /\s/
const hasWhitespace = (str) => whitespaceRegex.test(str)
const quoteOnWhitespace = (token) =>
  hasWhitespace(token) ? quote(token) : token

const targetValue =
  (fn) =>
    ({ target: { value } }, ...args) =>
      fn(value, ...args)

// consider an init vs state push thing.
const inputRef = createRef()
const root = document.getElementById('issue-search')
root.innerHTML = ''

const search = (state, push) => {
  const { specialTokens, issuesPerToken, query, tokens } = state

  const queryInput = inputRef.value

  const onQueryChange = (query) => {
    push((state) => {
      state.query = query
      return state
    })
  }

  const onSelectionChange = ({ target }) => {
    push(identity)
  }

  const onMouseUp = (event) => {
    onSelectionChange(event)
  }

  const onKeyUp = (event) => {
    onSelectionChange(event)
  }

  const onInput = (event) => {
    targetValue(onQueryChange)(event)
  }

  const onTokenRemove = (index) => {
    onQueryChange(excludeIndex(index, state.tokens).join(' '))
  }

  const onSuggestionClick = (token) => (_event) => {
    const [before, after] = indexSplit(queryInput.selectionStart, state.query)

    onQueryChange([...butLast(before.split(' ')), token, after].join(' '))

    queryInput.focus()

    // TODO: Jump to just behind the newly added token with a space in
    // between.
    // const selectionStart = b;
    // state.queryInput.setSelectionRange(selectionStart, selectionStart);
  }

  const suggestions = call(() => {
    if (!queryInput) return

    // How to find the token you are editing? Diff?
    const current = last(
      indexSplit(queryInput.selectionStart, query)[0].split(' ')
    )

    const tokens = specialTokens.filter((x) => x.startsWith(current))

    // Do not show suggestions when the only matching special token is an exact
    // match with the current token.
    if (isEmpty(current) || (tokens.length === 1 && tokens[0] === current)) {
      return html`<p class="issue-suggestions"></p>`
    }

    return html`<p class="issue-suggestions">
      ${tokens.map(
        (token) =>
          html`<button
            @click=${onSuggestionClick(token)}
            class="issue-suggestion"
          >
            ${token}
          </button>`
      )}
    </p>`
  })

  const searchTokenItem = (token, index, tokens) => {
    console.log(token, index, tokens)
    const count = issuesPerToken[token] || 0

    if (token === 'or') {
      return html`<li class="issue-search-query-or-item">or</li>`
    }

    return html`<li>
      <button
        class="issue-search-query-item"
        title="Remove ${token}"
        value="${token}"
        @click="${partial(onTokenRemove, index)}"
      >
        ${tokenIcon(token[0])} ${quoteOnWhitespace(token)}
        <span class="badge badge-primary">${count}</span>
      </button>
    </li>`
  }

  render(
    html`
      <input
        placeholder="terms..."
        id="issue-search-input"
        ${ref(inputRef)}
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
  )
}

const tokenIcon = byKey(
  {
    '#': '🏷️',
    '@': '🧑',
    '"': '🔤',
    '/': '📁'
  },
  '🔤'
)

export default search
