# Assertive for Promises

**Assertive as Promised** extends [Assertive][assertive] for asserting things
about standards-compliant promises.  It is 100% backward-compatible, so all of
the existing assertive documentation applies.

## How to Use

This is best used with something like [Mocha] (version >= 1.18.0) which
handles returned promises correctly.  All of assertive's assertions are
extended to accept promises as their argument to be tested and return a
promise which will be resolved or rejected.

For all existing assertive functions, you may simply replace the
argument with a promise for an equivalent argument.
`assert.equal('foo', funcThatReturnsAString())` becomes
`assert.equal('foo', funcThatReturnsAPromiseForAString())`.  Note that you may
get nicer and more consistent errors if you put any function calls that may
have a risk of throwing an exception synchronously inside a bluebird
`Promise.try()`, thusly:
`assert.equal('foo', Promise.try -> funcThatReturnsAPromiseForAString())`

Note for `throws()` and `notThrows()` that they accept a function (which may
throw a *synchronous* exception) or a promise for a function (which
may throw a *synchronous* exception).  The resolution status of the promise
itself is not being tested.  Since you're often more interested in the
resolution status of the promise, there are two new functions:
`rejects` and `resolves`:

`assert.rejects(-> funcThatReturnsAPromise(someArg))` takes as its
argument a promise OR a function that returns a promise.  The equivalent
counterpart to `notThrows` is called `resolves`.  `rejects` returns a promise
for the rejection error, and thus composes nicely with other assertions.

## Examples (using Mocha)

```coffee
{ runSync, runAsync }  = require './some-library'
assert  = require 'assertive-as-promised'
Promise = require 'bluebird'
# runAsync returns a promise

it 'runs synchronously', ->
  assert.deepEqual 'got proper hash', { a: 42 }, runSync('good')

it 'fails synchronously', ->
  assert.throws 'fails on bad', -> runSync('bad')

it 'runs asynchronously', ->
  assert.deepEqual 'got proper hash', { a: 42 }, runAsync('good')

it 'fails asynchronously', ->
  assert.rejects 'fails on bad', -> runAsync('bad')

fn = -> Promise.try -> throw 'kaboom'
it 'fails asynchronously with the proper error', ->
  assert.equal 'kaboom', assert.rejects fn
```

Note that if you want to be able to put more than one asynchronous test in a
single `it()`, you'll need to combine them somehow to make `mocha-as-promised`
happy, e.g.:

```coffee
{ runAsync } = require './some-library'
assert       = require 'assertive-as-promised'
Promise      = require 'bluebird'

it 'runs and fails asynchronously', ->
  Promise.all [
    assert.deepEqual 'got proper hash', { a: 42 }, runAsync('good')
    assert.rejects 'fails on bad', -> runAsync('bad')
  ]
```

(this may be bad style, depending on who you ask, but I find it useful if you
have `it()`s with a lot of setup overhead)

## Development

* `src/aap.coffee` is the main library; it compiles to `lib/aap.js`.
* `test/assertive_test.coffee` is a copy of the [assertive] library tests, slightly modified to run correctly in our test environment (see comments at the top)

[assertive]: https://github.com/groupon/assertive
[Mocha]: https://mochajs.org/
