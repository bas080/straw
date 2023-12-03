import { identity, excludeIndex, notEquals, isEmpty } from "./helpers.mjs";

const state = (initial) => {
  let registered = [];
  let oldState = initial();
  let queue = true;

  return function register(onState) {
    // Creates a unique reference for this function.
    const internalOnState = (state) => onState(state, pushState);
    const index = registered.length;

    registered.push(internalOnState);
    pushState(identity);

    function pushState(...args) {
      // Removes the listener when no arguments are pushed.
      if (args.length === 0) {
        registered = excludeIndex(index, registered);
        return;
      }

      const [newValue] = args;

      oldState = newValue(oldState);

      if (queue) {
        queueMicrotask(() => {
          oldState = registered.reduce(
            (acc, fn) => fn(acc),
            newValue(oldState),
          );
          oldState = registered.reduce((acc, fn) => fn(acc), oldState);
          queue = true;
        });
        queue = false;
      }
    }
  };
};

// helpers
const firstCallSymbol = Symbol("firstCall");

const onChange = (hasChanged = notEquals) => {
  let old = firstCallSymbol;
  return (value, cb) => {
    if (hasChanged(value, old) || old === firstCallSymbol)
      cb(value, old === firstCallSymbol ? value : old);

    old = value;
  };
};

export default state;
export { onChange };
