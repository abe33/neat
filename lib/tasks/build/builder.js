(function() {
  var Build, Builder, Neat, Q, compileCoffee, fs, glob, logs, path, processors,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  fs = require('fs');

  path = require('path');

  glob = require('glob');

  Q = require('q');

  compileCoffee = require('coffee-script').compile;

  Neat = require('../../neat');

  Build = require('./build');

  logs = Neat.require('utils/logs');

  processors = Neat.require('processing');

  Builder = (function() {
    function Builder() {
      this.loadNeatfile = __bind(this.loadNeatfile, this);      this.builds = [];
      this.unit = Q.defer();
    }

    Builder.prototype.init = function() {
      var _this = this;

      return this.loadNeatfile().then(this.compileNeatfile()).then(function(neatfile) {
        var build, load;

        logs.puts(logs.yellow('Neatfile loaded'));
        load = function(path) {
          return fs.readFileSync(Neat.rootResolve(path));
        };
        build = function(name, block) {
          var b;

          b = new Build(name);
          block.call(_this, b);
          return _this.builds.push(b);
        };
        return eval("" + (_this.getLocals(processors)) + "\n" + neatfile);
      }).then(function() {
        var build, promise, runBuild, _i, _len, _ref;

        logs.puts(logs.yellow('Neatfile evaluated'));
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
      }).fail(function(err) {
        console.error(err.message);
        return console.error(err.stack);
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
      processors.each(function(name, collection) {
        return lines.push("var " + name + " = processors." + name + ";");
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
        return compileCoffee(neatfile);
      };
    };

    return Builder;

  })();

  module.exports = Builder;

}).call(this);
