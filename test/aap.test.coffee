Promise = require 'bluebird'
test    = require 'assertive-as-promised' # old, known working copy for testing
assert  = require '../'

backwardCompatible =
  truthy:
    pass:
      args: [true], descr: 'a truthy promise resolution'
    fail:
      args: [false]
      descr: 'a falsey promise resolution'
      explain: 'resolves to true'

  equal:
    pass: args: [5, 5], descr: 'an equal promise resolution'
    fail:
      args: [5, 6]
      descr: 'an inequal promise resolution'
      explain: '5 is 5'

  deepEqual:
    pass:
      args: [['a', 'b'], ['a', 'b']]
      descr: 'a deep equal promise resolution'
    fail:
      args: [['a', 'b'], 'x']
      descr: 'a deep inequal promise resolution'
      explain: 'a,b is a,b'

  include:
    pass:
      args: ['x', 'fox']
      descr: 'needle inclusion in haystack promise resolution'
    fail:
      args: ['x', 'dog']
      descr: 'needle exclusion from haystack promise resolution'
      explain: 'x in word'

  match:
    pass: args: [/x/, 'fox'], descr: 'match /x/'
    fail:
      args: [/x/, 'dog']
      descr: 'needle exclusion from haystack promise resolution'
      explain: '/x/ matches word'

  throws:
    pass:
      args: [-> throw 'foo']
      descr: 'a promise for an excepting function'
    fail:
      args: [ -> 'foo' ]
      descr: 'a promise for a non-excepting function'
      explain: 'function throws an exception'

  notThrows:
    pass:
      args: [-> 42]
      descr: 'a non-excepting function'
    fail:
      args: [ -> throw 'foo' ]
      descr: 'a promise for an excepting function'
      explain: 'function does not throw an exception'

  hasType:
    pass:
      args: [Boolean, true]
      descr: 'matched type on promise resolution'
    fail:
      args: [Boolean, 'true']
      descr: 'mismatched type on promise resolution'
      explain: 'result is a boolean'

describe 'assertive backward-compatible functions', ->
  for name, bits of backwardCompatible
    do (name, bits) ->
      {pass, fail} = bits
      for pf, {args} of bits
        bits[pf].pargs ?= args[0...args.length-1].concat(
          [Promise.resolve(args[args.length-1])])

      describe "#{name}()", ->
        it 'returns a promise when passed a promise', ->
          test.truthy assert[name](pass.pargs...) instanceof Promise

        it 'does not return a promise when not passed one', ->
          test.falsey assert[name](pass.args...) instanceof Promise

        it "resolves for #{pass.descr}", ->
          test.resolves "#{name} should succeed", -> assert[name] pass.pargs...

        it "rejects for #{fail.descr}", ->
          test.rejects "#{name} should throw", ->
            assert[name] fail.explain, fail.pargs...
          .then (err) -> test.include fail.explain, err.message

describe 'assert-as-promised new functions', ->
  describe 'rejects()', ->
    it 'always returns a promise', ->
      test.truthy assert.rejects(Promise.resolve 42) instanceof Promise
      test.truthy assert.rejects(-> 42) instanceof Promise

    it 'errors on invalid argument', ->
      test.match /^rejects expects/, test.throws(-> assert.rejects 42).message

    it 'resolves for a synchronously erroring function', ->
      test.equal 'kittens', assert.rejects -> throw 'kittens'

    it 'resolves for a function which returns a rejected promise', ->
      test.equal 'kittens', assert.rejects -> Promise.reject 'kittens'

    it 'resolves for a rejected promise', ->
      test.equal 'kittens', assert.rejects Promise.reject 'kittens'

    it 'rejects for a function which returns a resolved promise', ->
      test.equal "Promise wasn't rejected as expected to",
        test.rejects(assert.rejects -> Promise.resolve 42).get('message')

    it 'rejects a resolved promise', ->
      test.equal "Promise wasn't rejected as expected to",
        test.rejects(assert.rejects Promise.resolve 42).get('message')

  describe 'resolves()', ->
    it 'always returns a promise', ->
      test.truthy assert.resolves(Promise.resolve 42) instanceof Promise
      test.truthy assert.resolves(-> 42) instanceof Promise

    it 'errors on invalid argument', ->
      test.match /^resolves expects/, test.throws(-> assert.resolves 42).message

    it 'rejects for a synchronously erroring function', ->
      test.include 'Promise was rejected despite resolves assertion:\n42',
        test.rejects(assert.resolves -> throw new Error 42).get('message')

    it 'rejects for a function which returns a rejected promise', ->
      test.include 'Promise was rejected despite resolves assertion:\n42',
        test.rejects(assert.resolves -> Promise.reject new Error 42).get(
          'message'
        )

    it 'rejects for a rejected promise', ->
      test.include 'Promise was rejected despite resolves assertion:\n42',
        test.rejects(assert.resolves Promise.reject new Error 42).get(
          'message'
        )

    it 'resolves for a function which returns a resolved promise', ->
      test.equal 'kittens', assert.resolves -> Promise.resolve 'kittens'

    it 'resolves for a resolved promise', ->
      test.equal 'kittens', assert.resolves Promise.resolve 'kittens'
