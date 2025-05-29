// @ts-check
import test from 'tape'
import { check, gen } from 'tape-check'
import { parse, stringify, removeToken, predicate } from './queryan.js'

const overToken = (str) => (cb) => stringify(cb(parse(str)))

test(
  'Parse and stringify back and forth',
  check(gen.string, (t, value) => {
    t.plan(1)
    t.equals(value, stringify(parse(value)))
  })
)

test('removeToken', (t) => {
  const overABC = overToken('a b c')
  const overOr = overToken('a or b')

  t.deepEqual(
    overABC((abc) => removeToken(abc, abc[0])),
    'b c'
  )
  t.deepEqual(
    overABC((abc) => removeToken(abc, abc[2])),
    'a c'
  )

  t.equals(
    overOr((tokens) => removeToken(tokens, tokens[4])),
    'a'
  )

  t.equals(
    overOr((tokens) => removeToken(tokens, tokens[0])),
    'b'
  )

  t.end()
})

test('predicate', (t) => {
  const items = ['abc', 'abcd', 'bcd']

  const query = (query, items) => {
    return items.filter(
      predicate(([value], string) => string.includes(value))(parse(query))
    )
  }

  t.deepEqual(query('a b', items), ['abc', 'abcd'])
  t.deepEqual(query('a or b', items), items)

  t.deepEqual(query('c a or b', items), items)
  t.deepEqual(query('d a or b', items), ['abcd', 'bcd'])

  t.deepEqual(query('a or e', items), ['abc', 'abcd'], 'a or e')

  t.deepEqual(query('-a', items), ['bcd'], '- (negate)')
  t.deepEqual(query('-a or a', items), items)
  t.deepEqual(query('-a or a -b or b', items), items)
  t.deepEqual(query('-a -b', items), [])


  t.end()
})
