// @ts-check

import { predicate, parse } from './queryan.js'
import { call, string, uniq } from './helpers.js'
import search from './search.mjs'
import issuesFn from './issues.mjs'
import state from './state.mjs'

const issues = Array.from(document.querySelectorAll('.straw-issues article'))
const issueElementsByToken = call(() => {
  const directoryTokenRegex = /\w+(?=\/)/g
  const otherTokensRegex = /[@#]\w+/g

  return issues.reduce((acc, elem) => {
    const bookmark = elem.querySelector('.straw-bookmark')

    uniq(bookmark.textContent.match(directoryTokenRegex)).forEach((token) => {
      token = `/${token}`

      acc[token] = acc[token] || []
      acc[token].push(elem)
    })

    uniq(elem.textContent.match(otherTokensRegex)).forEach((token) => {
      acc[token] = acc[token] || []
      acc[token].push(elem)
    })

    return acc
  }, {})
})

const query = predicate(([token], value) => {
  token = token.startsWith('/') ? string.tail(token) : token

  return value?.textContent?.includes(token) || false
})

const specialTokens = Object.keys(issueElementsByToken)

const tokenIssues = (token) => {
  return (
    issueElementsByToken[token] ||
    issues.filter((issue) => issue.textContent.includes(token))
  )
}

state(
  () => ({
    query: getQueryParam('q') || '',
    tokens: [],
    issuesPerToken: {},
    issues,
    specialTokens,
    issueElementsByToken
  }),
  (state, push) => {
    // Keep hash up to date with state.
    if (state.query) setQueryParam('q', state.query)
    else deleteQueryParam('q')

    state.tokens = parse(state.query)

    const predicate = query(state.tokens)

    state.issuesPerToken = state.tokens.reduce((acc, [token]) => {
      acc[token] = tokenIssues(token).length

      return acc
    }, {})

    // What to do with things that are not a token?
    state.matchedIssueElements = issues.filter(predicate)

    search(state, push)
    issuesFn(state)

    return state
  }
)

function getQueryParam (parameterName) {
  const urlParams = new URLSearchParams(window.location.search)
  return urlParams.get(parameterName)
}

function setQueryParam (parameterName, newValue) {
  const urlParams = new URLSearchParams(window.location.search)
  urlParams.set(parameterName, newValue)

  const newUrl = `${window.location.pathname}?${urlParams.toString()}${
    window.location.hash
  }`
  window.history.replaceState({}, document.title, newUrl)
}

function deleteQueryParam (parameterName) {
  const urlParams = new URLSearchParams(window.location.search)
  urlParams.delete(parameterName)

  const newUrl = `${window.location.pathname}?${urlParams.toString()}${
    window.location.hash
  }`
  window.history.replaceState({}, document.title, newUrl)
}

export default null
