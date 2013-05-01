(function() {
  var Neat, Packager, basename, chain, compile, ensure, extname, glob, green, parallel, print, puts, readFiles, red, resolve, writeFile, yellow, _, _ref, _ref1, _ref2, _ref3;

  glob = require('glob');

  compile = require('coffee-script').compile;

  writeFile = require('fs').writeFile;

  _ref = require('path'), resolve = _ref.resolve, basename = _ref.basename, extname = _ref.extname;

  Neat = require('../../neat');

  _ref1 = Neat.require('async'), chain = _ref1.chain, parallel = _ref1.parallel;

  _ref2 = Neat.require('utils/files'), readFiles = _ref2.readFiles, ensure = _ref2.ensure;

  _ref3 = Neat.require('utils/logs'), green = _ref3.green, yellow = _ref3.yellow, red = _ref3.red, print = _ref3.print, puts = _ref3.puts;

  _ = Neat.i18n.getHelper();

  Packager = (function() {
    Packager.asCommand = function(conf, path) {
      return function(callback) {
        return new Packager(conf, path).process(callback);
      };
    };

    function Packager(conf, path) {
      var k, malformedConf, operator, preventMissingConf, _i, _len, _ref4,
        _this = this;

      this.conf = conf;
      this.path = path;
      malformedConf = function(key, type) {
        throw new Error(_('neat.tasks.package.invalid_configuration', {
          key: key,
          type: type
        }));
      };
      preventMissingConf = function(key) {
        if (_this.conf[key] == null) {
          throw new Error(_('neat.tasks.package.missing_configuration', {
            key: key
          }));
        }
      };
      preventMissingConf('includes');
      preventMissingConf('operators');
      if (!Array.isArray(this.conf['includes'])) {
        malformedConf('includes', 'Array');
      }
      if (!Array.isArray(this.conf['operators'])) {
        malformedConf('operators', 'Array');
      }
      this.conf.merge(Neat.config.tasks["package"]);
      this.operators = (function() {
        var _i, _len, _ref4, _results;

        _ref4 = this.conf.operators;
        _results = [];
        for (_i = 0, _len = _ref4.length; _i < _len; _i++) {
          k = _ref4[_i];
          _results.push(this.conf.operatorsMap[k]);
        }
        return _results;
      }).call(this);
      _ref4 = this.operators;
      for (_i = 0, _len = _ref4.length; _i < _len; _i++) {
        operator = _ref4[_i];
        if (typeof operator.validate === "function") {
          operator.validate(this.conf);
        }
      }
    }

    Packager.prototype.process = function(callback) {
      var _this = this;

      return this.find(this.conf.includes, function(err, files) {
        _this.conf.files = files;
        return readFiles(files, function(err, res) {
          var errCallback;

          errCallback = function(err) {
            var stack;

            puts(yellow(_('neat.tasks.package.process', {
              file: basename(_this.path)
            })), 5);
            stack = err.stack.split('\n');
            stack[0] = red(stack[0]);
            puts("" + (stack.join('\n')) + "\n", 5);
            return typeof callback === "function" ? callback(1) : void 0;
          };
          return chain.call(null, _this.operators, res, _this.conf, errCallback, function(buffer) {
            var k;

            _this.result = buffer;
            puts("" + (yellow(_('neat.tasks.package.process', {
              file: basename(_this.path)
            }))) + "\n" + (((function() {
              var _results;

              _results = [];
              for (k in this.result) {
                _results.push(green('.'));
              }
              return _results;
            }).call(_this)).join('')) + "\n" + (green(_('neat.tasks.package.processed', {
              files: _this.result.length()
            }))) + "\n", 5);
            return typeof callback === "function" ? callback(0) : void 0;
          });
        });
      });
    };

    Packager.prototype.find = function(paths, callback) {
      var f, files, p;

      files = [];
      f = function(p) {
        return function(cb) {
          if (extname(p) === '') {
            p = "" + p + ".coffee";
          }
          return glob(resolve(Neat.root, p), {}, function(err, fs) {
            files = files.concat(fs);
            return cb();
          });
        };
      };
      return parallel((function() {
        var _i, _len, _results;

        _results = [];
        for (_i = 0, _len = paths.length; _i < _len; _i++) {
          p = paths[_i];
          _results.push(f(p));
        }
        return _results;
      })(), function() {
        return callback(null, files.uniq().map(function(f) {
          return resolve(Neat.root, f);
        }));
      });
    };

    return Packager;

  })();

  module.exports = Packager;

}).call(this);
