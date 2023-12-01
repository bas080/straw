import { html, render } from "lit-html";
import { createRef, ref } from "lit-html/directives/ref.js";
import {
  isEmpty,
  indexSplit,
  butLast,
  last,
  byKey,
  excludeIndex,
  partial,
} from "./helpers.mjs";

const quote = (str) => `"${str}"`;
const whitespaceRegex = /\s/;
const hasWhitespace = (str) => whitespaceRegex.test(str);
const quoteOnWhitespace = (token) =>
  hasWhitespace(token) ? quote(token) : token;

const targetValue =
  (fn) =>
  ({ target: { value } }, ...args) =>
    fn(value, ...args);

const register = (onState) => {
  onState((state, push) => {
    const onQueryChange = (query) => {
      push((state) => {
        state.query = query;
        return state;
      });
    };

    const onSelectionChange = ({ target }) => {
      push((state) => {
        state.inputSelectionStart = state.queryInput.selectionStart;

        return state;
      });
    };

    state.onMouseUp = (event) => {
      onSelectionChange(event);
      push((state) => {
        return state;
      });
    };

    state.onKeyUp = (event) => {
      onSelectionChange(event);
    };

    state.onInput = (event) => {
      targetValue(onQueryChange)(event);
      onSelectionChange(event);
    };

    state.onTokenRemove = (index) => {
      onQueryChange(excludeIndex(index, state.tokens).join(" "));
    };

    state.onSuggestionClick = (token) => (_event) => {
      const [before, after] = indexSplit(
        state.inputSelectionStart,
        state.query,
      );

      onQueryChange([...butLast(before.split(" ")), token, after].join(" "));

      state.queryInput.focus();

      // TODO: Jump to just behind the newly added token with a space in
      // between.
      // const selectionStart = b;
      // state.queryInput.setSelectionRange(selectionStart, selectionStart);
    };

    // render
    render(searchTemplate(state), document.getElementById("issue-search"));

    // communicate the tokens outside of this module.
    return state;
  });
};

const tokenIcon = byKey(
  {
    "#": "🏷️",
    "@": "🧑",
    '"': "🔎",
    "/": "📁",
  },
  "🔎",
);

const searchTokenItem = (state, token, index, tokens) => {
  const { onTokenRemove } = state;
  const count = state.issuesPerToken[token];

  if (token === "or") {
    return html`<li class="issue-search-query-or-item">or</li>`;
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
  </li>`;
};

const suggestions = (state) => {
  // How to find the token you are editing? Diff?
  const current = last(
    indexSplit(state.inputSelectionStart, state.query)[0].split(" "),
  );

  const tokens = state.specialTokens.filter((x) => x.startsWith(current));

  // Do not show suggestions when the only matching special token is an exact
  // match with the current token.
  if (isEmpty(current) || (tokens.length === 1 && tokens[0] === current)) {
    return html`<p class="issue-suggestions"></p>`;
  }

  return html`<p class="issue-suggestions">
    ${tokens.map(
      (token) =>
        html`<button
          @click=${state.onSuggestionClick(token)}
          class="issue-suggestion"
        >
          ${token}
        </button>`,
    )}
  </p>`;
};

const inputRef = createRef();

const searchTemplate = (state) => {
  const { onKeyUp, onMouseUp, onInput, tokens } = state;

  state.queryInput = inputRef.value;

  return html`<input
      placeholder="terms..."
      id="issue-search-input"
      ${ref(inputRef)}
      .value="${state.query}"
      @keyup=${onKeyUp}
      @mouseup=${onMouseUp}
      @input=${onInput}
    />
    ${suggestions(state)}
    <ul class="issue-search-query-items">
      ${tokens.map(partial(searchTokenItem, state))}
    </ul>`;
};

export default register;
