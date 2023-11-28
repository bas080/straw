import { html, render } from "lit-html";
import { byKey, excludeIndex, partial } from "./helpers.mjs";

const targetValue =
  (fn) =>
  ({ target: { value } }, ...args) =>
    fn(value, ...args);

const register = (onState) => {
  onState((state, push) => {
    // mutations
    state.onQueryChange = (query) => {
      push((state) => {
        state.query = query;
        return state;
      });
    };

    state.onTokenRemove = (index) => {
      state.onQueryChange(excludeIndex(index, state.tokens).join(" "));
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

  return html`<li>
    <button
      class="issue-search-query-item"
      title="Remove ${token}"
      value="${token}"
      @click="${partial(onTokenRemove, index)}"
    >
      ${tokenIcon(token[0])} ${token}
      <span class="badge badge-primary">${count}</span>
    </button>
  </li>`;
};

const searchTemplate = (state) => {
  const { onQueryChange, tokens } = state;

  return html`<input
      placeholder="terms..."
      id="issue-search-input"
      .value="${state.query}"
      @input=${targetValue(onQueryChange)}
    />
    <ul class="issue-search-query-items">
      ${tokens.map(partial(searchTokenItem, state))}
    </ul>`;
};

export default register;
