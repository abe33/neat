(function() {
  var compile, error, getMember, getValue, puts, read, resolve, spawn, write, _ref;

  resolve = require('path').resolve;

  spawn = require('child_process').spawn;

  compile = require('coffee-script').compile;

  _ref = require('./logs'), puts = _ref.puts, error = _ref.error;

  read = function(str) {
    var e;

    try {
      return eval(compile("" + str, {
        bare: true
      }));
    } catch (_error) {
      e = _error;
      return null;
    }
  };

  write = function(o) {
    var k, s, v;

    s = '';
    for (k in o) {
      v = o[k];
      s += getMember(k, v, o);
    }
    return s.replace(/\n\s*\n|\s*\n/g, '\n').strip().replace(/\t/g, "*");
  };

  getMember = function(k, v, o, i) {
    if (i == null) {
      i = '';
    }
    return "" + k + ": " + (getValue(v, i)) + "\n";
  };

  getValue = function(v, i) {
    var m, n, o;

    if (i == null) {
      i = '';
    }
    switch (typeof v) {
      case 'number':
        return v;
      case 'string':
        return "'" + v + "'";
      case 'boolean':
        return v;
      case 'object':
        if (RegExp.prototype.isPrototypeOf(v)) {
          return v;
        } else if (Array.prototype.isPrototypeOf(v)) {
          return "[" + (((function() {
            var _i, _len, _results;

            _results = [];
            for (_i = 0, _len = v.length; _i < _len; _i++) {
              n = v[_i];
              _results.push("\n" + i + "  " + (getValue(n, i)));
            }
            return _results;
          })()).join('')) + "\n]";
        } else {
          return ((function() {
            var _results;

            _results = [];
            for (m in v) {
              o = v[m];
              _results.push("\n" + i + "  " + (getMember(m, o, v, i + '  ')));
            }
            return _results;
          })()).join('');
        }
        break;
      case 'function':
        return "`" + (v.toString()) + "`";
    }
  };

  module.exports = {
    read: read,
    write: write
  };

}).call(this);
