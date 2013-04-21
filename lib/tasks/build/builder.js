(function() {
  var Builder, Neat, Q, compile, fs, glob, path, processors,
    _this = this;

  fs = require('fs');

  path = require('path');

  glob = require('glob');

  Q = require('q');

  compile = require('coffee-script').compile;

  Neat = require('../../neat');

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
          b = {
            sources: [],
            processors: [],
            "do": function(promise) {
              this.processors.push(promise);
              return this;
            },
            then: function(promise) {
              this.processors.push(promise);
              return this;
            },
            source: function(path) {
              return this.sources.push(path);
            }
          };
          block.call(_this, b);
          return _this.builds.push(b);
        };
        return eval("" + (_this.getLocals(processors)) + "\n" + neatfile);
      }).fail(function(err) {
        return console.error(err);
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
