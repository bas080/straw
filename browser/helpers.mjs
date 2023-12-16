const call = (fn, ...args) => fn(...args)
const isNil = (x) => x == null
const partial = (fn, ...args) => fn.bind(null, ...args)
const isEmpty = (x) => x.length === 0
const isOdd = (x) => x % 2 === 1
const excludeIndex = (index, array) => {
  const result = Array.prototype.slice.call(array, 0)

  result.splice(index, 1)

  return result
}
const noop = () => {}
const identity = (x) => x
const equals = (a, b) => a === b
const tail = ([, ...tail]) => tail
const once = (fn) => {
  let called = false
  let returned
  return (...args) => {
    if (called) return returned
    called = true
    returned = fn(...args)
    return returned
  }
}

const complement =
  (fn) =>
    (...args) =>
      !fn(...args)

const indexSplit = (i, str) => [str.substring(0, i), str.substring(i)]
const butLast = (arr) => arr.slice(0, -1)
const last = (arr) => arr[arr.length - 1]
const notEquals = complement(equals)
const isNotEmpty = complement(isEmpty)
const byKey = (object, defaultTo) => (key) => object[key] || defaultTo
const tap =
  (fn) =>
    (returned, ...args) => {
      fn(returned, ...args)

      return returned
    }

const isNotNil = complement(isNil)
const debounce = (milli, fn) => {
  let timeout

  return (...args) => {
    if (timeout) clearTimeout(timeout)

    timeout = setTimeout(() => {
      fn(...args)
    }, milli)
  }
}

const string = {
  prepend: (a) => (b) => a + b
}
const always = (x) => () => x

export {
  string,
  always,
  call,
  isNil,
  isNotNil,
  byKey,
  tail,
  notEquals,
  isEmpty,
  excludeIndex,
  isNotEmpty,
  isOdd,
  noop,
  identity,
  partial,
  tap,
  butLast,
  last,
  indexSplit,
  debounce,
  once
}
