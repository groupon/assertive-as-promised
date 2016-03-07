
/*
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
 */
var Promise, aap, assert, clear, emsg, fn, fn1, green, isPromiseAlike, name, red,
  slice = [].slice,
  hasProp = {}.hasOwnProperty;

Promise = require('bluebird');

assert = require('assertive');

aap = {};

green = function(x) {
  return "\x1B[32m" + x + "\x1B[39m";
};

red = function(x) {
  return "\x1B[31m" + x + "\x1B[39m";
};

clear = "\x1b[39;49;00m";

emsg = function(message, explanation) {
  if (explanation != null) {
    message = "Assertion failed: " + explanation + "\n" + clear + message;
  }
  return message;
};

isPromiseAlike = function(p) {
  return p === Object(p) && 'function' === typeof p.then;
};

aap.rejects = function(expln, testee, name) {
  var ref;
  if (name == null) {
    name = 'rejects';
  }
  if (testee != null) {
    assert.hasType("argument 1 of " + name + " must be a doc string", String, expln);
  } else {
    ref = [expln, null], testee = ref[0], expln = ref[1];
  }
  if (!isPromiseAlike(testee)) {
    if ('function' !== typeof testee) {
      throw new Error(name + " expects " + (green('a function or promise')) + " but got " + (red(testee)));
    }
    testee = Promise["try"](testee);
  }
  if (name === 'rejects') {
    return testee.then(function() {
      throw new Error(emsg("Promise wasn't rejected as expected to", expln));
    }, function(err) {
      return err;
    });
  } else {
    return testee["catch"](function(err) {
      var ref1;
      throw new Error(emsg("Promise was rejected despite resolves assertion:\n" + ((ref1 = err != null ? err.message : void 0) != null ? ref1 : err), expln));
    });
  }
};

aap.resolves = function(expln, testee) {
  return aap.rejects(expln, testee, 'resolves');
};

fn1 = function(name, fn) {
  return aap[name] != null ? aap[name] : aap[name] = function() {
    var args, testee;
    args = 1 <= arguments.length ? slice.call(arguments, 0) : [];
    if (!args.length) {
      return fn();
    }
    testee = args.pop();
    if (isPromiseAlike(testee)) {
      return testee.then(function(val) {
        return fn.apply(null, slice.call(args).concat([val]));
      });
    } else {
      return fn.apply(null, slice.call(args).concat([testee]));
    }
  };
};
for (name in assert) {
  if (!hasProp.call(assert, name)) continue;
  fn = assert[name];
  fn1(name, fn);
}

if ((typeof module !== "undefined" && module !== null ? module.exports : void 0) != null) {
  module.exports = aap;
} else {
  global.assert = aap;
}
