# Improve state module performance

All listeners are called twice for each state push. This is not ideal as
multiple pushes can occur on one event. Let's say you have 5 listeners and
2 pushes. The amount of calls end up being:

```js
listeners = [1,2,3,4,5]

calls = [
  firstPushState,
  ...listeners,
  ...listeners,
  secondsPushState,
  ...listeners,
  ...listeners,
]
```

This double walking over the listeners has to happen because state of one
listener can be the dependency of another listener.

A more ideal situation would be to compose all the push call within that tick
and then walk the listeners twice.

```js
calls = [
  firstPushState,
  secondsPushState,
  ...listeners,
  ...listeners
]
```

We can cut down the amount of calls by quite a bit. Especially when the amount
of pushes is on the high side.

Conceptually this should be backwards compatible as these amount of passes
should allow for the state to stabilize.

\#browser #performance

assigned:@bas080
