const partial = (fn, ...args) => fn.bind(null, ...args);
const isEmpty = (x) => x.length === 0;
const isOdd = (x) => x % 2 === 1;
const excludeIndex = (index, array) => {
  const result = Array.prototype.slice.call(array, 0);

  result.splice(index, 1);

  return result;
};
const noop = () => {};
const identity = (x) => x;
const equals = (a, b) => a === b;
const tail = ([, ...tail]) => tail;

const complement =
  (fn) =>
  (...args) =>
    !fn(...args);

const notEquals = complement(equals);
const isNotEmpty = complement(isEmpty);
const byKey = (object, defaultTo) => (key) => object[key] || defaultTo;

export {
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
};
