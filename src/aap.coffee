###
Copyright (c) 2014, Groupon, Inc.
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:

Redistributions of source code must retain the above copyright notice,
this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.

Neither the name of GROUPON nor the names of its contributors may be
used to endorse or promote products derived from this software without
specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
###

Promise = require 'bluebird'
assert  = require 'assertive'
aap     = {}

# TODO: use some sort of future extensibility framework from assertive
green = (x) -> "\x1B[32m#{ x }\x1B[39m"
red   = (x) -> "\x1B[31m#{ x }\x1B[39m"
clear = "\x1b[39;49;00m"
emsg  = (message, explanation) ->
  if explanation?
    message = "Assertion failed: #{explanation}\n#{clear}#{message}"
  message

# borrowed from Q
isPromiseAlike = (p) -> p is Object(p) and 'function' is typeof p.then

aap.rejects = (expln, testee, name='rejects') ->
  if testee?
    assert.hasType "argument 1 of #{name} must be a doc string", String, expln
  else
    [testee, expln] = [expln, null]

  unless isPromiseAlike testee
    unless 'function' is typeof testee
      throw new Error "#{name} expects #{green 'a function or promise'} but got #{red testee}"
    testee = Promise.try testee

  if name is 'rejects'
    testee.then(
      -> throw new Error emsg "Promise wasn't rejected as expected to", expln
      (err) -> err
    )
  else
    testee.catch (err) ->
      throw new Error emsg """Promise was rejected despite resolves assertion:
                              #{err?.message ? err}""", expln

aap.resolves = (expln, testee) -> aap.rejects expln, testee, 'resolves'

for own name, fn of assert
  do (name, fn) ->
    aap[name] ?= (args...) ->
      return fn() unless args.length
      testee = args.pop()
      if isPromiseAlike testee
        testee.then (val) -> fn args..., val
      else
        fn args..., testee

# export as a module to node - or to the global scope, if not
if module?.exports?
  module.exports = aap
else
  global.assert = aap
