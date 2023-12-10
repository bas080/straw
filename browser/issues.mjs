import { html, render } from "lit-html";
import { onChange } from "./state.mjs";
import { isEmpty, uniq } from "./helpers.mjs";

function mapFocusable(elem, cb) {
  for (const focusable of elem.querySelectorAll("a")) {
    cb(focusable);
  }
}

export default function issues(onState) {
  const issues = Array.from(document.getElementsByClassName("issue-issue"));
  const index = issues.map((issue) => [issue, issue.textContent]);

  const issuesPerToken = (tokens) => {
    tokens = uniq(tokens);
    return index.reduce((acc, [, content]) => {
      tokens.forEach((token) => {
        acc[token] = (acc[token] || 0) + Number(content.includes(token));
      });
      return acc;
    }, {});
  };

  const onQueryChange = onChange();

  // Most of the code in onState should only be run if tokens has changed.
  onState((state, push) => {
    const { tokens } = state;

    // Push computed state when the query changes.
    onQueryChange(state.query, (a, b) => {
      push((state) => {
        state.issuesPerToken = issuesPerToken(tokens);

        return state;
      });
    });

    const ors = tokens.reduce(
      (acc, token) => {
        if (token === "or") return [[], ...acc];

        acc[0].push(token);

        return acc;
      },
      [[]],
    );

    function fuzzy(text) {
      let matched;

      return ors.some((tokens) =>
        tokens.every((token) => text.includes(token)),
      );
    }

    state.matchedCount = 0;
    state.issuesCount = 0;
    index.forEach(([elem, content]) => {
      state.issuesCount += 1;
      if (isEmpty(state.tokens) || fuzzy(content)) {
        state.matchedCount += 1;
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

    document.getElementById("issue-search-count").innerText =
      `Matched ${state.matchedCount} / ${state.issuesCount}`;

    return state;
  });
}
