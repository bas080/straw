// @ts-check

import {
  parse,
  stringify,
  isOrToken,
  isRightOfOr,
  removeToken,
  replaceTokenValue,
  tokenFromStringIndex,
  map
} from './queryan'
import { html, render } from 'lit-html'
import { createRef, ref } from 'lit-html/directives/ref.js'
import { identity, call, byKey, partial } from './helpers.ts'

const targetValue =
  (fn) =>
    ({ target: { value } }, ...args) =>
      fn(value, ...args)

// consider an init vs state push thing.
const inputRef = createRef()
const root = document.getElementById('straw-search')
root.innerHTML = ''

const tokenIcon = byKey(
  {
    '#': '🏷️',
    '@': '🧑',
    '"': '🔤',
    '/': '📁'
  },
  '🔤'
)

export default function search (state, push) {
  const { specialTokens, issuesPerToken, query } = state

  const tokens = parse(query)

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

  const onTokenRemove = (token, tokens) => {
    onQueryChange(stringify(removeToken(tokens, token)))
  }

  const onSuggestionClick = (token, value) => (_event) => {
    onQueryChange(stringify(replaceTokenValue(tokens, token, value)))

    queryInput.focus()

    // TODO: Jump to just behind the newly added token with a space in
    // between.
    // const selectionStart = b;
    // state.queryInput.setSelectionRange(selectionStart, selectionStart);
  }

  const suggestions = call(() => {
    if (!queryInput) return html`<p></p>`

    const currentToken = tokenFromStringIndex(
      tokens,
      queryInput.selectionStart
    )

    if (currentToken == null) return html`<p class="straw-suggestions"></p>`

    const [current] = currentToken

    const startsWith = specialTokens.filter(
      (x) => x.startsWith(current) && current !== x
    )

    return html`<p class="straw-suggestions">
      ${startsWith.map(
        (token) =>
          html`<button
            @click=${onSuggestionClick(currentToken, token)}
            class="straw-suggestion"
          >
            ${token}
          </button>`
      )}
    </p>`
  })

  const searchTokenItem = (token, _index, tokens) => {
    const [value] = token
    const count = issuesPerToken[value] || 0

    if (isOrToken(token)) {
      return html`<li>or</li>`
    }

    return [
      isRightOfOr(token, tokens) || token[1] === 0
        ? null
        : html`<div class="separator">and</div>`,
      html`<li>
        <button
          class="straw-search-query-item"
          title="Remove ${value}"
          value="${value}"
          @click="${partial(onTokenRemove, token, tokens)}"
        >
          ${tokenIcon(value[0])} ${value}
          <span class="badge badge-primary">${count}</span>
        </button>
      </li>`
    ]
  }

  render(
    html`
      <textarea
        rows="5"
        placeholder="terms..."
        id="straw-search-input"
        ${ref(inputRef)}
        .value="${query}"
        @keyup=${onKeyUp}
        @mouseup=${onMouseUp}
        @input=${onInput}
      ></textarea>
      ${suggestions}
      <ul class="straw-search-query-items">
        ${map(searchTokenItem, tokens)}
      </ul>
    `,
    root
  )
}
