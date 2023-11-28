import { onChange } from "./state.mjs";
import { isEmpty } from "./helpers.mjs";

function mapFocusable(elem, cb) {
  for (const focusable of elem.querySelectorAll("a")) {
    cb(focusable);
  }
}

export default function search(onState) {
  const issues = Array.from(document.getElementsByClassName("issue-issue"));
  const index = issues.map((issue) => [issue, issue.textContent]);

  const issuesPerToken = (tokens) => {
    return index.reduce((acc, [, content]) => {
      tokens.forEach((token) => {
        acc[token] = (acc[token] || 0) + Number(content.includes(token));
      });
      return acc;
    }, {});
  };

  const onQueryChange = onChange();

  onState((state, push) => {
    const { tokens } = state;

    // Push computed state when the query changes.
    onQueryChange(state.query, (a, b) => {
      console.log("onQueryChange", JSON.stringify(a), JSON.stringify(b));
      push((state) => {
        state.issuesPerToken = issuesPerToken(tokens);
        return state;
      });
    });

    // Consider adding a better search.
    function fuzzy(text, str) {
      return tokens.every((token) => text.includes(token));
    }

    index.forEach(([elem, content]) => {
      if (isEmpty(state.tokens) || fuzzy(content, search)) {
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

    return state;
  });
}
