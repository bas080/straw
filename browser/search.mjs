import { html, render } from "lit-html";
import { byKey, isNotEmpty, isOdd, removeIndex, partial } from "./helpers.mjs";

const targetValue =
  (fn) =>
  ({ target: { value } }, ...args) =>
    fn(value, ...args);

const preventDefault =
  (fn) =>
  (event, ...args) => {
    event.preventDefault();
    return fn(event, ...args);
  };

const register = (onState) => {
  onState((state, push) => {
    const { query } = state;

    // mutations
    state.onQueryChange = (query) => {
      push((state) => {
        state.query = query;
        return state;
      });
    };

    state.onTokenRemove = (index) => {
      state.onQueryChange(removeIndex(index, state.tokens).join(" "));
    };

    // render
    render(searchTemplate(state), document.getElementById("lit-app"));

    // communicate the tokens outside of this module.
    return state;
  });
};

const searchTokens = (query) => {
  return query
    .split('"')
    .reduce((acc, value, index) => {
      if (isOdd(index)) return [...acc, `"${value}"`];

      return acc.concat(value.split(" "));
    }, [])
    .filter(isNotEmpty);
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

  // Should I be creating a new function for eacht element?
  const onClick = preventDefault((event) => {
    onInput(removeIndex(index, tokens).join(" "));
  });

  return html`<li>
    <button
      class="issue-search-query-item"
      title="Remove ${token}"
      value="${token}"
      @click="${partial(onTokenRemove, index)}"
    >
      ${tokenIcon(token)} ${token}
      <span class="badge badge-primary">${count}</span>
    </button>
  </li>`;
};

const searchTemplate = (state) => {
  const { onQueryChange, tokens } = state;

  return html`<input
      .value="${state.query}"
      @input=${targetValue(onQueryChange)}
    />
    <ul class="issue-search-query-items">
      ${tokens.map(partial(searchTokenItem, state))}
    </ul>`;
};

export default register;
