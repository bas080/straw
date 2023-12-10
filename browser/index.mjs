import { isNotEmpty, isOdd } from "./helpers.mjs";
import search from "./search.mjs";
import issues from "./issues.mjs";
import state from "./state.mjs";

const specialTokens = (() => {
  const directoryTokenRegex = /\/\w+(?=\/)/g;
  const otherTokensRegex = /[@#]\w+/g;

  const { textContent } = document.querySelector(".issue-issues");

  return Array.from(
    new Set([
      ...textContent.match(directoryTokenRegex),
      ...textContent.match(otherTokensRegex),
    ]),
  );
})();

const searchTokens = (query) => {
  return query
    .split('"')
    .reduce((acc, value, index) => {
      if (isOdd(index)) return [...acc, `${value}`];

      return acc.concat(value.split(" "));
    }, [])
    .filter(isNotEmpty);
};

const onState = state(() => ({
  query: getQueryParam("q") || "",
  tokens: [],
  issuesPerToken: {},
  specialTokens,
}));

function getQueryParam(parameterName) {
  const urlParams = new URLSearchParams(window.location.search);
  return urlParams.get(parameterName);
}

function setQueryParam(parameterName, newValue) {
  const urlParams = new URLSearchParams(window.location.search);
  urlParams.set(parameterName, newValue);

  const newUrl = `${window.location.pathname}?${urlParams.toString()}${
    window.location.hash
  }`;
  history.replaceState({}, document.title, newUrl);
}

function deleteQueryParam(parameterName) {
  const urlParams = new URLSearchParams(window.location.search);
  urlParams.delete(parameterName);

  const newUrl = `${window.location.pathname}?${urlParams.toString()}${
    window.location.hash
  }`;
  history.replaceState({}, document.title, newUrl);
}

onState((state) => {
  // Keep hash up to date with state.
  if (state.query) setQueryParam("q", state.query);
  else deleteQueryParam("q");

  state.tokens = searchTokens(state.query);
  return state;
});

search(onState);
issues(onState);
