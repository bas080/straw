import { remove, isOdd, filter } from './helpers.js'

import test from 'tape'

const integers = [1, 2, 3, 4, 5, 6]

test('filter', (t) => {
  t.deepEquals(filter(isOdd)(integers), [1, 3, 5])

  t.end()
})

test('remove', (t) => {
  t.deepEqual(remove(0, 1, integers), [3, 4, 5, 6])
  t.deepEqual(remove(1, -1, integers), [3, 4, 5, 6])
  t.end()
})
