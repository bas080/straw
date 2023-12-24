type Object = { [key: string]: any };

const remove = <T>(start: number, count: number, array: T[]): T[] =>
  count < 0
    ? remove(start + count, Math.abs(count), array)
    : array.slice(0, start).concat(array.slice(start + count + 1));
const call = (fn: Function, ...args: any) => fn(...args);
const isNil = (x: any) => x == null;
const partial = (fn: Function, ...args: any) => fn.bind(null, ...args);
const isEmpty = (x: string | any) => x.length === 0;
const isOdd = (x: number) => x % 2 === 1;
const excludeIndex = (index: number, array: any) => {
  const result = Array.prototype.slice.call(array, 0);

  result.splice(index, 1);

  return result;
};
const noop = () => {};
const identity = (x: any) => x;
const equals = (a: any, b: any) => a === b;
const tail = <T>([, ...tail]: T[]): T[] => tail;

const once = <T>(fn: Function) => {
  let called = false;
  let returned: T;
  return (...args: any): T => {
    if (called) return returned;
    called = true;
    returned = fn(...args);
    return returned;
  };
};

type Predicate = (...args: any) => Boolean;

const complement =
  (fn: Predicate) =>
  (...args: any): boolean =>
    !fn(...args);

const filter = (pred: Predicate) => (array: any) => array.filter(pred);
const indexSplit = (i: number, str: string) => [
  str.substring(0, i),
  str.substring(i),
];
const butLast = <T>(arr: T[]): T[] => arr.slice(0, -1);
const last = <T>(arr: T[]): T => arr[arr.length - 1];
const notEquals = complement(equals);
const isNotEmpty = complement(isEmpty);
const byKey = (object: Object, defaultTo: any) => (key: string) =>
  object[key] ?? defaultTo;
const tap =
  (fn: Function) =>
  (returned: any, ...args: any) => {
    fn(returned, ...args);

    return returned;
  };

const isNotNil = complement(isNil);
const debounce = (milli: number, fn: Function) => {
  let timeout: ReturnType<typeof setTimeout> | null;

  return (...args: any) => {
    if (timeout) clearTimeout(timeout);

    timeout = setTimeout(() => {
      fn(...args);
    }, milli);
  };
};

const string = {
  prepend: (a: string) => (b: string) => a + b,
  tail: (a: string): string => a.substring(1),
};
const always =
  <T>(x: T) =>
  (): T =>
    x;
const T = always(true);

const uniq = <T>(array: T[]): T[] => [...new Set(array)];

export {
  uniq,
  T,
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
  complement,
  remove,
  filter,
  once,
};
