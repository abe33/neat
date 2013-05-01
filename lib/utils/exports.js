(function() {
  var basename, combine, error, findSync, missing, namespace, puts, resolve, warn, _ref, _ref1;

  _ref = require('path'), resolve = _ref.resolve, basename = _ref.basename;

  _ref1 = require('./logs'), puts = _ref1.puts, error = _ref1.error, warn = _ref1.warn, missing = _ref1.missing;

  findSync = require("../utils/files").findSync;

  namespace = function(namespace, exports) {
    var k, packaged, v;

    packaged = {};
    if (exports["index"] != null) {
      packaged[namespace] = exports["index"];
    }
    for (k in exports) {
      v = exports[k];
      if (k !== "index") {
        packaged["" + namespace + ":" + k] = v;
      }
    }
    return packaged;
  };

  combine = function(filePattern, paths) {
    var e, file, files, k, packaged, required, s, v, _i, _len, _ref2;

    if (Array.isArray(filePattern)) {
      _ref2 = [paths, filePattern], filePattern = _ref2[0], paths = _ref2[1];
    }
    files = findSync(filePattern, 'js', paths);
    packaged = {};
    for (_i = 0, _len = files.length; _i < _len; _i++) {
      file = files[_i];
      try {
        required = require(file);
        for (k in required) {
          v = required[k];
          packaged[k] = v;
        }
      } catch (_error) {
        e = _error;
        s = error("" + ("Broken file " + file).red + "\n\n" + e.stack);
        error(s.red);
      }
    }
    return packaged;
  };

  module.exports = {
    namespace: namespace,
    combine: combine
  };

}).call(this);
