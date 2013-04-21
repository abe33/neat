(function() {
  var Build, Builder, Neat, Q, compile, fs, glob, path, processors,
    _this = this;

  fs = require('fs');

  path = require('path');

  glob = require('glob');

  Q = require('q');

  compile = require('coffee-script').compile;

  Neat = require('../../neat');

  Build = require('./build');

  processors = Neat.require('processing');

  Builder = (function() {

    function Builder() {
      var _this = this;
      this.loadNeatfile = function() {
        return Builder.prototype.loadNeatfile.apply(_this, arguments);
      };
      this.builds = [];
      this.unit = Q.defer();
    }

    Builder.prototype.init = function() {
      var _this = this;
      return this.loadNeatfile().then(this.compileNeatfile()).then(function(neatfile) {
        var build;
        build = function(name, block) {
          var b;
          b = new Build(name);
          block.call(_this, b);
          return _this.builds.push(b);
        };
        return eval("" + (_this.getLocals(processors)) + "\n" + neatfile);
      }).then(function() {
        var build, promise, runBuild, _i, _len, _ref;
        runBuild = function(build) {
          return function() {
            return build.process();
          };
        };
        promise = Q.fcall(function() {});
        _ref = _this.builds;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          build = _ref[_i];
          promise = promise.then(runBuild(build));
        }
        return promise;
      });
    };

    Builder.prototype.glob = function(path) {
      var defer;
      defer = Q.defer();
      glob(path, defer.makeNodeResolver());
      return defer.promise;
    };

    Builder.prototype.getLocals = function(processors) {
      var lines;
      lines = [];
      processors.each(function(pkg, collection) {
        return collection.each(function(name, processor) {
          return lines.push("var " + name + " = processors." + pkg + "." + name + ";");
        });
      });
      return lines.join('\n');
    };

    Builder.prototype.loadNeatfile = function() {
      var defer;
      defer = Q.defer();
      fs.readFile("" + Neat.root + "/Neatfile", function(err, neatfile) {
        if (err != null) {
          return defer.reject(err);
        }
        return defer.resolve(neatfile.toString());
      });
      return defer.promise;
    };

    Builder.prototype.compileNeatfile = function() {
      var _this = this;
      return function(neatfile) {
        return compile(neatfile);
      };
    };

    return Builder;

  })();

  module.exports = Builder;

}).call(this);
