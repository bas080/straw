import { html, render } from "lit-html";
import { isNotEmpty, isOdd, removeIndex, identity } from "./helpers.mjs";
import search from "./search.mjs";
import issues from "./issues.mjs";
import state from "./state.mjs";

const searchTokens = (query) => {
  return query
    .split('"')
    .reduce((acc, value, index) => {
      if (isOdd(index)) return [...acc, `"${value}"`];

      return acc.concat(value.split(" "));
    }, [])
    .filter(isNotEmpty);
};

const onState = state(() => ({
  query: getQueryParam("q") || "",
  tokens: [],
  issuesPerToken: {},
}));

onState((state) => {
  // Keep hash up to date with state.
  if (state.query) updateQueryParam("q", state.query);
  else deleteQueryParam("q");

  state.tokens = searchTokens(state.query);
  return state;
});

function getQueryParam(parameterName) {
  const urlParams = new URLSearchParams(window.location.search);
  return urlParams.get(parameterName);
}

function updateQueryParam(parameterName, newValue) {
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

search(onState);
issues(onState);
