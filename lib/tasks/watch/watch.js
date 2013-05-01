(function() {
  var Neat, Q, Watch, glob;

  glob = require('glob');

  Q = require('q');

  Neat = require('../../neat');

  Watch = (function() {
    function Watch(regexp, options, block) {
      this.regexp = regexp;
      this.options = options != null ? options : {};
      this.block = block;
    }

    Watch.prototype.match = function(path) {
      return this.regexp.test(path);
    };

    Watch.prototype.outputPathsFor = function(path) {
      var paths, pattern;

      if (this.block != null) {
        paths = this.block.apply(null, [path].concat(this.regexp.exec(path)));
        paths = typeof paths === 'string' ? [paths] : paths;
      } else {
        paths = [path];
      }
      return Q.all((function() {
        var _i, _len, _results;

        _results = [];
        for (_i = 0, _len = paths.length; _i < _len; _i++) {
          pattern = paths[_i];
          _results.push(this.glob(Neat.resolve(pattern)));
        }
        return _results;
      }).call(this)).then(function(paths) {
        return paths.flatten();
      });
    };

    Watch.prototype.glob = function(pattern) {
      var defer;

      defer = Q.defer();
      glob(pattern, function(err, paths) {
        if (err != null) {
          return defer.reject(err);
        }
        return defer.resolve(paths);
      });
      return defer.promise;
    };

    Watch.prototype.toString = function() {
      return "[object Watch(" + this.regexp + ")]";
    };

    return Watch;

  })();

  module.exports = Watch;

}).call(this);
