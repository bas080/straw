import { tap } from './helpers.mjs'
import { test } from 'tape'
import { check, gen } from 'tape-check'
import state from './state.mjs'

test(
  'Calls listener on creation',
  check(gen.any, (t, value) => {
    t.plan(2)

    state(
      () => {
        t.pass('Is being called on init')
        return value
      },
      tap((state) =>
        t.equals(
          state,
          value,
          'The value set in init is available in listener'
        )
      )
    )
  })
)

test(
  'Computed state should stay updated',
  check(gen.int, (t, int) => {
    t.plan(11)

    state(
      () => ({
        value: int,
        till: int + 10
      }),
      (state, push) => {
        t.equals(state.value, state.value, 'Value is equal to the test value')

        if (state.value < state.till) {
          push((state) => {
            state.value += 1
            return state
          })
        } else {
          t.end()
        }

        return state
      }
    )
  })
)
