(function() {
  var Neat, Packager, chain, compile, ensure, glob, parallel, readFiles, resolve, writeFile, _, _ref, _ref1;

  glob = require('glob');

  compile = require('coffee-script').compile;

  writeFile = require('fs').writeFile;

  resolve = require('path').resolve;

  Neat = require('../../neat');

  _ref = Neat.require('async'), chain = _ref.chain, parallel = _ref.parallel;

  _ref1 = Neat.require('utils/files'), readFiles = _ref1.readFiles, ensure = _ref1.ensure;

  _ = Neat.i18n.getHelper();

  Packager = (function() {

    Packager.asCommand = function(conf) {
      return function(callback) {
        return new Packager(conf).process(callback);
      };
    };

    function Packager(conf) {
      var k, malformedConf, operator, preventMissingConf, _i, _len, _ref2,
        _this = this;
      this.conf = conf;
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
        var _i, _len, _ref2, _results;
        _ref2 = this.conf.operators;
        _results = [];
        for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
          k = _ref2[_i];
          _results.push(this.conf.operatorsMap[k]);
        }
        return _results;
      }).call(this);
      _ref2 = this.operators;
      for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
        operator = _ref2[_i];
        if (typeof operator.validate === "function") {
          operator.validate(this.conf);
        }
      }
    }

    Packager.prototype.process = function(callback) {
      var _this = this;
      return this.find(this.conf.includes, function(err, files) {
        return readFiles(files, function(err, res) {
          return chain.call(null, _this.operators, res, _this.conf, function(buffer) {
            _this.result = buffer;
            return typeof callback === "function" ? callback() : void 0;
          });
        });
      });
    };

    Packager.prototype.find = function(paths, callback) {
      var f, files, p;
      files = [];
      f = function(p) {
        return function(cb) {
          if (p.indexOf('*') === -1) {
            p = resolve(Neat.root, "" + p + ".coffee");
            return cb(files.push(p));
          } else {
            return glob(p, {}, function(err, fs) {
              files = files.concat(fs);
              return cb();
            });
          }
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
        return callback(null, files.map(function(f) {
          return resolve(Neat.root, f);
        }));
      });
    };

    return Packager;

  })();

  module.exports = Packager;

}).call(this);
