import { notEquals } from './helpers.js'

const state = (initial, onPush) => {
  let oldState

  const push = (cb) => {
    oldState = cb(oldState)
    oldState = onPush(oldState, push)

    return oldState
  }

  oldState = initial()
  oldState = onPush(oldState, push)

  return push
}

// helpers
const firstCallSymbol = Symbol('firstCall')

const onChange = (hasChanged = notEquals) => {
  let old = firstCallSymbol
  return (value, cb) => {
    if (hasChanged(value, old) || old === firstCallSymbol) {
      cb(value, old === firstCallSymbol ? value : old)
    }

    old = value
  }
}

export default state
export { onChange }
