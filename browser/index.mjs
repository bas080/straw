import { intersection, uniq, isNotEmpty, isOdd, call } from './helpers.mjs'
import search from './search.mjs'
import issuesFn from './issues.mjs'
import state from './state.mjs'

const issueElementsByToken = call(() => {
  const issueElements = document.querySelectorAll('.issue-issues article')
  const directoryTokenRegex = /\w+(?=\/)/g
  const otherTokensRegex = /[@#]\w+/g

  return Array.from(issueElements).reduce((acc, elem) => {
    const bookmark = elem.querySelector('.issue-bookmark')

    bookmark.textContent.match(directoryTokenRegex)?.forEach((token) => {
      token = `/${token}`

      acc[token] = acc[token] || []
      acc[token].push(elem)
    })

    elem.textContent.match(otherTokensRegex)?.forEach((token) => {
      acc[token] = acc[token] || []
      acc[token].push(elem)
    })

    return acc
  }, {})
})

const specialTokens = Object.keys(issueElementsByToken)

const searchTokens = (query) => {
  return query
    .split('"')
    .reduce((acc, value, index) => {
      if (isOdd(index)) return [...acc, `${value}`]

      return acc.concat(value.split(' '))
    }, [])
    .filter(isNotEmpty)
}

const issues = Array.from(document.querySelectorAll('.issue-issues article'))
const index = issues.map((issue) => [issue, issue.textContent])

const onState = state(() => ({
  query: getQueryParam('q') || '',
  tokens: [],
  issuesPerToken: {},
  issues,
  specialTokens,
  issueElementsByToken
}))

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

onState((state) => {
  // Keep hash up to date with state.
  if (state.query) setQueryParam('q', state.query)
  else deleteQueryParam('q')

  state.tokens = searchTokens(state.query)
  state.issuesPerToken = state.tokens.reduce((acc, token) => {
    acc[token] =
      issueElementsByToken[token]?.length ||
      index.filter(([, content]) => content.includes(token)).length

    return acc
  }, {})

  const ors = state.tokens.reduce(
    (acc, token) => {
      if (token === 'or') return [[], ...acc]

      acc[0].push(token)

      return acc
    },
    [[]]
  )

  // What to do with things that are not a token?
  state.matchedIssueElements = state.query
    ? uniq(
      ors.flatMap((tokens) => {
        return (
          tokens.reduce((acc, token) => {
            if (acc === null) return issueElementsByToken[token] || issues

            return intersection(acc, issueElementsByToken[token] || issues)
          }, null) || []
        )
      })
    )
    : issues

  return state
})

// Consider only passing the push. Computed properties can therefore still be
// part of the component.
search(onState)
issuesFn(onState)
