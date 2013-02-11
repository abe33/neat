(function() {
  var CLASS_MEMBER_RE, CLASS_RE, EXPORTS_RE, HASH_KEY_RE, HASH_RE, HASH_VALUE_RE, LITERAL_RE, MEMBER_RE, NAME_RE, OBJECT_RE, PACKAGE_RE, Q, REQUIRE_RE, SPLIT_MEMBER_RE, STATIC_MEMBER_RE, STRING_RE, analyze, annotate, coffee, compile;

  Q = require('q');

  coffee = require('coffee-script').compile;

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
    var comment, curClass, i, i2, line, m, out, p, s, _i, _len, _ref, _ref1, _ref2;
    out = content.concat();
    i2 = 0;
    curClass = null;
    for (i = _i = 0, _len = content.length; _i < _len; i = ++_i) {
      line = content[i];
      comment = null;
      if (CLASS_RE().test(line)) {
        _ref = CLASS_RE().exec(line), m = _ref[0], s = _ref[1], curClass = _ref[2];
        comment = "" + s + "`/* " + path + "<" + curClass + "> line:" + (i + 1) + " */`";
      }
      if (CLASS_MEMBER_RE().test(line)) {
        _ref1 = CLASS_MEMBER_RE().exec(line), m = _ref1[0], s = _ref1[1], p = _ref1[2];
        comment = "" + s + "`/* " + path + "<" + curClass + "::" + p + "> line:" + (i + 1) + " */`";
      }
      if (STATIC_MEMBER_RE().test(line)) {
        _ref2 = STATIC_MEMBER_RE().exec(line), m = _ref2[0], s = _ref2[1], p = _ref2[2];
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
    return Q.fcall(function() {
      var content, path;
      for (path in buffer) {
        content = buffer[path];
        content = content.split('\n');
        content = analyze(path, content);
        buffer[path] = "`/* " + path + " */`\n" + (content.join('\n'));
      }
      return buffer;
    });
  };

  compile = function(options) {
    return function(buffer) {
      return Q.fcall(function() {
        var content, newBuffer, path;
        newBuffer = {};
        try {
          for (path in buffer) {
            content = buffer[path];
            newBuffer[path.replace('.coffee', '.js')] = coffee(content, options);
          }
        } catch (e) {
          throw new Error("In file '" + path + "': " + e.message);
        }
        return newBuffer;
      });
    };
  };

  module.exports = {
    compile: compile,
    annotate: annotate
  };

}).call(this);
