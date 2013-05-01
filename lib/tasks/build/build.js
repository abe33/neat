(function() {
  var Build, Neat, Q, glob, logs, processors;

  glob = require('glob');

  Q = require('q');

  Neat = require('../../neat');

  logs = Neat.require('utils/logs');

  processors = Neat.require('processing');

  Build = (function() {
    function Build(name) {
      this.name = name;
      this.sources = [];
      this.processors = [];
    }

    Build.prototype.source = function(path) {
      return this.sources.push(Neat.rootResolve(path));
    };

    Build.prototype["do"] = function(promise) {
      this.processors.push(promise);
      return this;
    };

    Build.prototype.then = Build.prototype["do"];

    Build.prototype.fail = function(handler) {
      this.failHandler = handler;
      return this;
    };

    Build.prototype.process = function() {
      var promise,
        _this = this;

      promise = this.findSources().then(function(files) {
        return _this.loadBuffer(files);
      }).then(function(buffer) {
        return _this.processBuffer(buffer);
      }).then(function() {
        return logs.info(logs.green("" + _this.name + " build completed"));
      });
      if (this.failHandler != null) {
        promise.fail(this.failHandler);
      }
      return promise;
    };

    Build.prototype.findSources = function() {
      var findOneSources, source;

      findOneSources = function(path) {
        var defer;

        defer = Q.defer();
        glob(path, {}, function(err, results) {
          if (err != null) {
            return defer.reject(err);
          }
          return defer.resolve(results);
        });
        return defer.promise;
      };
      return Q.all((function() {
        var _i, _len, _ref, _results;

        _ref = this.sources;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          source = _ref[_i];
          _results.push(findOneSources(source));
        }
        return _results;
      }).call(this)).then(function(paths) {
        return paths.flatten().uniq();
      });
    };

    Build.prototype.loadBuffer = function(paths) {
      return processors.readFiles(paths);
    };

    Build.prototype.processBuffer = function(buffer) {
      var processor, promise, _i, _len, _ref;

      promise = Q.fcall(function() {
        return buffer;
      });
      _ref = this.processors;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        processor = _ref[_i];
        promise = promise.then(processor).fail(function(err) {
          return console.log("failed in processor " + processor + " with " + err + "\n" + err.stack);
        });
      }
      return promise;
    };

    Build.prototype.toString = function() {
      return "[Build: " + this.name + "]";
    };

    return Build;

  })();

  module.exports = Build;

}).call(this);
