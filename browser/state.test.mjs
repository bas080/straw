import { tap, isNotNil } from './helpers.mjs'
import { test } from 'tape';
import { check, gen } from 'tape-check';
import state from './state.mjs'

test('Calls listener on creation', check(gen.any, (t, value) => {
  t.plan(3)

  const onState = state(() => {
    t.pass('Is being called on init')
    return value
  })

  onState(tap(state => t.equals(state, value, 'The value set in init is available in listener')))
}))

test('Computed state should stay updated', check(gen.int, (t, int) => {
  t.plan(11)

  const onState = state(() => {
    return {
      value: int
    }
  })

  // Should eventually include the computed property
  onState(tap(state => {
    t.equals(state.value, int, 'Value is equal to the test value')

    if (isNotNil(state.computed)) {
      t.equals(int + 1, state.computed, 'Computed is one more than int eventually')
    }
  }))

  onState(state => ({
    ...state,
    computed: state.value + 1,
  }))

  onState(tap(state => {
    t.equals(int + 1, state.computed, 'Computed is one more than int eventually')
  }))
}))
