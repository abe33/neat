(function() {
  var I18n, NEAT_ROOT, Neat, Signal, cup, error, existsSync, findSync, fs, isNeatRootSync, logger, missing, neatBroken, neatRootSync, path, pr, puts, resolve, warn, _ref, _ref1,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  fs = require('fs');

  pr = require('commander');

  path = require('path');

  resolve = path.resolve;

  existsSync = fs.existsSync || path.existsSync;

  NEAT_ROOT = resolve(__dirname, '..');

  _ref = require("./utils/logs"), logger = _ref.logger, puts = _ref.puts, warn = _ref.warn, error = _ref.error, missing = _ref.missing, neatBroken = _ref.neatBroken;

  _ref1 = require("./utils/files"), findSync = _ref1.findSync, neatRootSync = _ref1.neatRootSync, isNeatRootSync = _ref1.isNeatRootSync;

  cup = require("./utils/cup");

  require("./core");

  Signal = require("./core/signal");

  I18n = require("./i18n").I18n;

  Neat = (function() {
    function Neat(ROOT) {
      this.ROOT = ROOT;
      this.defaultEnvironment = 'default';
      this.root = this.ROOT;
      this.neatRoot = this.NEAT_ROOT = NEAT_ROOT;
      this.envPath = this.ENV_PATH = 'lib/config/environments';
      this.initPath = this.INIT_PATH = 'lib/config/initializers';
      this.paths = this.PATHS = [this.neatRoot];
      this.config = this.config = null;
      this.env = this.ENV = null;
      if (this.root != null) {
        this.discoverUserPaths();
      }
      this.initI18n();
      this.initHooks();
      this.meta = this.META = this.loadMeta(this.neatRoot);
      if (this.root != null) {
        this.project = this.PROJECT = this.loadMeta(this.root);
      }
    }

    Neat.prototype.initHooks = function() {
      this.beforeCommand = new Signal;
      this.afterCommand = new Signal;
      this.beforeCompilation = new Signal;
      this.afterCompilation = new Signal;
      this.beforeTask = new Signal;
      this.afterTask = new Signal;
      this.beforeEnvironment = new Signal;
      this.afterEnvironment = new Signal;
      this.beforeInitialize = new Signal;
      return this.afterInitialize = new Signal;
    };

    Neat.prototype.initI18n = function() {
      this.i18n = new I18n(this.paths.map(function(s) {
        return "" + s + "/config/locales";
      }));
      this.i18n.load();
      return puts("Available languages: " + (this.i18n.languages.join(', ')));
    };

    Neat.prototype.require = function(module) {
      return require("" + this.neatRoot + "/lib/" + module);
    };

    Neat.prototype.resolve = function(path) {
      return resolve(this.neatRoot, path);
    };

    Neat.prototype.rootResolve = function(path) {
      return resolve(this.root, path);
    };

    Neat.prototype.task = function(name) {
      return this.require('tasks')[name];
    };

    Neat.prototype.initLogging = function() {
      return logger.add(this.config.engines.logging[this.config.defaultLoggingEngine]);
    };

    Neat.prototype.initEnvironment = function(callback) {
      var _this = this;

      return this.setEnvironment(process.env['NEAT_ENV'] || this.defaultEnvironment, function() {
        _this.initLogging();
        return typeof callback === "function" ? callback() : void 0;
      });
    };

    Neat.prototype.setEnvironment = function(env, callback) {
      var envObject,
        _this = this;

      envObject = {
        root: this.root,
        neatRoot: this.neatRoot,
        paths: this.paths,
        initPath: this.initPath,
        envPath: this.envPath,
        ROOT: this.ROOT,
        NEAT_ROOT: this.NEAT_ROOT,
        PATHS: this.PATHS,
        INIT_PATH: this.INIT_PATH,
        ENV_PATH: this.ENV_PATH
      };
      return this.beforeEnvironment.dispatch(this, envObject, function() {
        var configurator, configurators, e, f, files, paths, setup, _i, _j, _len, _len1;

        paths = _this.paths.map(function(p) {
          return "" + p + "/" + _this.envPath;
        });
        configurators = findSync(/^default$/, 'js', paths);
        if (!((configurators != null) && configurators.length !== 0)) {
          return error("" + (_this.i18n.getHelper()('neat.errors.missing', {
            missing: 'config/environments/default.js'
          })) + "\n\n" + (_this.i18n.get('neat.errors.broken')));
        }
        files = findSync(RegExp("^" + env + "$"), "js", paths);
        for (_i = 0, _len = files.length; _i < _len; _i++) {
          f = files[_i];
          if (__indexOf.call(configurators, f) < 0) {
            configurators.push(f);
          }
        }
        for (_j = 0, _len1 = configurators.length; _j < _len1; _j++) {
          configurator = configurators[_j];
          puts("Running " + configurator);
          try {
            setup = require(configurator);
            if (typeof setup === "function") {
              setup(envObject);
            }
          } catch (_error) {
            e = _error;
            error("" + (_this.i18n.get('neat.errors.broken_environment').red) + "\n\n" + e.stack);
          }
        }
        return _this.afterEnvironment.dispatch(_this, envObject, function() {
          return _this.beforeInitialize.dispatch(_this, envObject, function() {
            var initialize, initializer, initializers, o, _k, _len2;

            initializers = findSync('js', _this.paths.map(function(o) {
              return "" + o + "/" + _this.initPath;
            }));
            for (_k = 0, _len2 = initializers.length; _k < _len2; _k++) {
              initializer = initializers[_k];
              try {
                initialize = require(initializer);
                if (typeof initialize === "function") {
                  initialize(envObject);
                }
              } catch (_error) {
                e = _error;
                error("" + (_this.i18n.get('neat.errors.broken_initializer').red) + "\n\n" + e.stack);
              }
            }
            _this.CONFIG = _this.config = envObject;
            o = {};
            o[env] = true;
            _this.ENV = _this.env = Object.prototype.merge.call(env, o);
            return _this.afterInitialize.dispatch(_this, envObject, callback);
          });
        });
      });
    };

    Neat.prototype.discoverUserPaths = function() {
      var m, modules, modulesDir, _i, _len, _ref2;

      modulesDir = resolve(this.root, 'node_modules');
      if (existsSync(modulesDir)) {
        modules = fs.readdirSync(modulesDir);
        modules = (function() {
          var _i, _len, _results;

          _results = [];
          for (_i = 0, _len = modules.length; _i < _len; _i++) {
            m = modules[_i];
            if (m !== 'neat') {
              _results.push(resolve(modulesDir, m));
            }
          }
          return _results;
        })();
        for (_i = 0, _len = modules.length; _i < _len; _i++) {
          m = modules[_i];
          if (isNeatRootSync(m)) {
            this.paths.push(m);
          }
        }
      } else {
        warn('No node modules found, run neat install.');
      }
      if (_ref2 = this.root, __indexOf.call(this.paths, _ref2) < 0) {
        return this.paths.push(this.root);
      }
    };

    Neat.prototype.loadMeta = function(root) {
      var e, meta, neatFile, neatFilePath, _;

      neatFilePath = "" + root + "/.neat";
      _ = this.i18n.getHelper();
      try {
        neatFile = fs.readFileSync(neatFilePath);
      } catch (_error) {
        e = _error;
        return error("" + (_('neat.errors.missing', {
          missing: neatFilePath.red
        })) + "\n\n" + (_('neat.errors.broken')));
      }
      meta = cup.read(neatFile.toString());
      return meta || error("" + (_('neat.errors.invalid_neat', {
        path: neatFilePath.red
      })) + "\n\n" + (_('neat.errors.broken')));
    };

    return Neat;

  })();

  module.exports = new Neat(neatRootSync());

}).call(this);
