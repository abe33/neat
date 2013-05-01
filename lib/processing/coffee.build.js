(function() {
  var CLASS_MEMBER_RE, CLASS_RE, EXPORTS_RE, HASH_KEY_RE, HASH_RE, HASH_VALUE_RE, LITERAL_RE, MEMBER_RE, NAME_RE, OBJECT_RE, PACKAGE_RE, Q, REQUIRE_RE, SPLIT_MEMBER_RE, STATIC_MEMBER_RE, STRING_RE, analyze, annotate, check, checkBuffer, coffee, compile, exportsToPackage, stripRequires, _ref;

  Q = require('q');

  coffee = require('coffee-script').compile;

  _ref = require('./utils'), check = _ref.check, checkBuffer = _ref.checkBuffer;

  LITERAL_RE = '[a-zA-Z_$][a-zA-Z0-9_$]*';

  STRING_RE = '["\'][^"\']+["\']';

  HASH_KEY_RE = "(" + LITERAL_RE + "|" + STRING_RE + ")";

  OBJECT_RE = "(\\s*" + HASH_KEY_RE + "(\\s*:\\s*([^,\\n}]+)))+";

  EXPORTS_RE = function() {
    return RegExp("(?:\\s|^)(module\\.exports|exports)(\\s*=\\s*\\n" + OBJECT_RE + "|[=\\[.\\s].+\\n)", "gm");
  };

  SPLIT_MEMBER_RE = function() {
    return /\s*=\s*/g;
  };

  MEMBER_RE = function() {
    return RegExp("\\[\\s*" + STRING_RE + "\\s*\\]|\\." + LITERAL_RE);
  };

  NAME_RE = function() {
    return /^[a-zA-Z_$][a-zA-Z0-9_$-.]*$/;
  };

  PACKAGE_RE = function() {
    return RegExp("^(" + LITERAL_RE + ")(\\." + LITERAL_RE + ")*$");
  };

  HASH_VALUE_RE = '(\\s*:\\s*([^,}]+))*';

  HASH_RE = function() {
    return RegExp("\\{(" + HASH_KEY_RE + HASH_VALUE_RE + ",*\\s*)+\\}");
  };

  REQUIRE_RE = function() {
    return RegExp("require\\s*(\\(\\s*)*" + STRING_RE, "gm");
  };

  CLASS_RE = function() {
    return RegExp("^([^#]*)class\\s*(" + LITERAL_RE + ")");
  };

  CLASS_MEMBER_RE = function() {
    return RegExp("^(\\s+)(" + LITERAL_RE + ")\\s*:\\s*(\\([^)]+\\)\\s*)*->");
  };

  STATIC_MEMBER_RE = function() {
    return RegExp("^(\\s+)@(" + LITERAL_RE + ")\\s*:\\s*(\\([^)]+\\)\\s*)*->");
  };

  analyze = function(path, content) {
    var comment, curClass, i, i2, line, m, out, p, s, _i, _len, _ref1, _ref2, _ref3;

    out = content.concat();
    i2 = 0;
    curClass = null;
    for (i = _i = 0, _len = content.length; _i < _len; i = ++_i) {
      line = content[i];
      comment = null;
      if (CLASS_RE().test(line)) {
        _ref1 = CLASS_RE().exec(line), m = _ref1[0], s = _ref1[1], curClass = _ref1[2];
        comment = "" + s + "`/* " + path + "<" + curClass + "> line:" + (i + 1) + " */`";
      }
      if (CLASS_MEMBER_RE().test(line)) {
        _ref2 = CLASS_MEMBER_RE().exec(line), m = _ref2[0], s = _ref2[1], p = _ref2[2];
        comment = "" + s + "`/* " + path + "<" + curClass + "::" + p + "> line:" + (i + 1) + " */`";
      }
      if (STATIC_MEMBER_RE().test(line)) {
        _ref3 = STATIC_MEMBER_RE().exec(line), m = _ref3[0], s = _ref3[1], p = _ref3[2];
        comment = "" + s + "`/* " + path + "<" + curClass + "." + p + "> line:" + (i + 1) + " */`";
      }
      if (comment != null) {
        out.splice(i2, 0, comment);
        i2++;
      }
      i2++;
    }
    return out;
  };

  annotate = function(buffer) {
    checkBuffer(buffer);
    return Q.fcall(function() {
      var content, newBuffer, path;

      newBuffer = {};
      for (path in buffer) {
        content = buffer[path];
        content = content.split('\n');
        content = analyze(path, content);
        newBuffer[path] = "`/* " + path + " */`\n" + (content.join('\n'));
      }
      return newBuffer;
    });
  };

  exportsToPackage = function(pkg) {
    check(pkg, 'Missing package argument');
    return function(buffer) {
      checkBuffer(buffer);
      return Q.fcall(function() {
        var content, convertExports, header, newBuffer, path;

        newBuffer = {};
        header = function() {
          var p, packages, _i, _len, _pkg;

          header = '';
          packages = pkg.split('.');
          _pkg = "@" + (packages.shift());
          header += "" + _pkg + " ||= {}\n";
          for (_i = 0, _len = packages.length; _i < _len; _i++) {
            p = packages[_i];
            _pkg += "." + p;
            header += "" + _pkg + " ||= {}\n";
          }
          return "" + header + "\n";
        };
        convertExports = function(content) {
          var exp, packageFor,
            _this = this;

          packageFor = function(k, v) {
            return "@" + pkg + "." + k + " = " + (v || k);
          };
          exp = [];
          content = content.replace(EXPORTS_RE(), function(m, e, p) {
            var k, member, v, value, values, _i, _j, _len, _len1, _ref1, _ref2, _ref3;

            _ref1 = p.split(SPLIT_MEMBER_RE()), member = _ref1[0], value = _ref1[1];
            if (MEMBER_RE().test(member)) {
              return "@" + pkg + p;
            } else {
              if (HASH_RE().test(value)) {
                values = value.replace(/\{|\}/g, '').strip().split(',').map(function(s) {
                  return s.strip().split(/\s*:\s*/);
                });
                for (_i = 0, _len = values.length; _i < _len; _i++) {
                  _ref2 = values[_i], k = _ref2[0], v = _ref2[1];
                  exp.push(packageFor(k, v));
                }
              } else if (RegExp("" + OBJECT_RE, "m").test(value)) {
                values = value.split('\n').map(function(s) {
                  return s.strip().split(/\s*:\s*/);
                });
                for (_j = 0, _len1 = values.length; _j < _len1; _j++) {
                  _ref3 = values[_j], k = _ref3[0], v = _ref3[1];
                  exp.push(packageFor(k, v));
                }
              } else {
                value = value.strip();
                exp.push("@" + pkg + "." + value + " = " + value);
              }
              return '';
            }
          });
          return "" + content + "\n" + (exp.join('\n'));
        };
        for (path in buffer) {
          content = buffer[path];
          newBuffer[path] = "" + (header()) + (convertExports(content));
        }
        return newBuffer;
      });
    };
  };

  compile = function(options) {
    if (options == null) {
      options = {};
    }
    return function(buffer) {
      checkBuffer(buffer);
      return Q.fcall(function() {
        var content, e, newBuffer, opts, path;

        newBuffer = {};
        try {
          for (path in buffer) {
            content = buffer[path];
            opts = options.concat();
            newBuffer[path.replace('.coffee', '.js')] = coffee(content, opts);
          }
        } catch (_error) {
          e = _error;
          throw new Error("In file '" + path + "': " + e.message);
        }
        return newBuffer;
      });
    };
  };

  stripRequires = function(buffer) {
    checkBuffer(buffer);
    return Q.fcall(function() {
      var content, newBuffer, path;

      newBuffer = {};
      for (path in buffer) {
        content = buffer[path];
        newBuffer[path] = content.split('\n').reject(function(s) {
          return REQUIRE_RE().test(s);
        }).join('\n');
      }
      return newBuffer;
    });
  };

  module.exports = {
    compile: compile,
    annotate: annotate,
    exportsToPackage: exportsToPackage,
    stripRequires: stripRequires
  };

}).call(this);
