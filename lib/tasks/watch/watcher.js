(function() {
  var Neat, Q, Watch, Watcher, asyncErrorTrap, compile, cyan, error, existsSync, fs, green, inverse, n, os, parallel, path, puts, red, warn, yellow, _ref,
    _this = this;

  fs = require('fs');

  os = require('os');

  path = require('path');

  Q = require('q');

  Neat = require('../../neat');

  Watch = require('./watch');

  n = Neat.require('notifications');

  parallel = Neat.require('async').parallel;

  compile = require('coffee-script').compile;

  _ref = Neat.require('utils/logs'), warn = _ref.warn, error = _ref.error, puts = _ref.puts, yellow = _ref.yellow, green = _ref.green, red = _ref.red, cyan = _ref.cyan, inverse = _ref.inverse;

  asyncErrorTrap = Neat.require('utils/commands').asyncErrorTrap;

  existsSync = fs.existsSync || path.existsSync;

  Watcher = (function() {

    function Watcher() {
      var _this = this;
      this.evaluateWatchfile = function(watchfile) {
        return Watcher.prototype.evaluateWatchfile.apply(_this, arguments);
      };
      this.registerWatchers = function() {
        return Watcher.prototype.registerWatchers.apply(_this, arguments);
      };
      this.rewatch = function(file, watcher) {
        return Watcher.prototype.rewatch.apply(_this, arguments);
      };
      this.watchDirectory = function(directory, watcher) {
        return Watcher.prototype.watchDirectory.apply(_this, arguments);
      };
      this.indexPaths = function() {
        return Watcher.prototype.indexPaths.apply(_this, arguments);
      };
      this.loadWatchignore = function() {
        return Watcher.prototype.loadWatchignore.apply(_this, arguments);
      };
      this.initializePlugins = function() {
        return Watcher.prototype.initializePlugins.apply(_this, arguments);
      };
      this.loadWatchfile = function() {
        return Watcher.prototype.loadWatchfile.apply(_this, arguments);
      };
      this.watcher = function(path) {
        return Watcher.prototype.watcher.apply(_this, arguments);
      };
      this.dispose = function() {
        return Watcher.prototype.dispose.apply(_this, arguments);
      };
      this.handleSigint = function() {
        return Watcher.prototype.handleSigint.apply(_this, arguments);
      };
      this.init = function() {
        return Watcher.prototype.init.apply(_this, arguments);
      };
      switch (os.platform()) {
        case 'darwin':
          this.notifier = new n.Notifier(new n.plugins.Growly);
          break;
        case 'linux':
          this.notifier = new n.Notifier(new n.plugins.NotifySend);
      }
      this.notifier.notify({
        success: true,
        title: 'Watchfile',
        message: 'loaded'
      });
    }

    Watcher.prototype.init = function() {
      var data, promise,
        _this = this;
      data = {};
      this.watches = {};
      promise = this.loadWatchignore().then(function(ignoreList) {
        return _this.ignoreList = data.ignoreList = ignoreList;
      }).then(this.indexPaths).then(function(paths) {
        _this.watchedPaths = paths.watchedPaths, _this.ignoredPaths = paths.ignoredPaths;
        return data = data.merge(paths);
      }).then(this.loadWatchfile).then(this.evaluateWatchfile).then(this.registerWatchers).then(function() {
        puts(green('Watcher initialized'));
        return puts(yellow("" + data.watchedPaths.length + " files watched"));
      }).then(this.initializePlugins).then(function() {
        return data;
      }).fail(function(err) {
        error(red(err.message));
        return puts(err.stack.join('\n'));
      });
      this.promise || (this.promise = promise);
      process.on('SIGINT', this.handleSigint);
      return promise;
    };

    Watcher.prototype.handleSigint = function() {
      var _ref1;
      if ((_ref1 = this.activePlugin) != null ? _ref1.isPending() : void 0) {
        puts(yellow("\n" + this.activePlugin + " interrupted"));
        return this.activePlugin.kill('SIGINT');
      } else {
        return process.exit(1);
      }
    };

    Watcher.prototype.dispose = function() {
      var k, plugin, promise, _ref1,
        _this = this;
      promise = Q.fcall(function() {
        var k, watch, _ref1;
        _ref1 = _this.watches;
        for (k in _ref1) {
          watch = _ref1[k];
          watch.close();
        }
        _this.watches = null;
        _this.ignoreList = null;
        _this.watchedPaths = null;
        _this.ignoredPaths = null;
        return process.removeListener('SIGINT', _this.handleSigint);
      });
      _ref1 = this.plugins;
      for (k in _ref1) {
        plugin = _ref1[k];
        promise = promise.then(function() {
          return plugin.dispose();
        });
      }
      return promise.then(function() {
        return _this.plugins = null;
      });
    };

    Watcher.prototype.isIgnored = function(file) {
      return this.ignoreList.some(function(i) {
        return RegExp("" + Neat.root + "/" + i).test(file);
      });
    };

    Watcher.prototype.watcher = function(path) {
      var changesSpacedEnough, lastTime,
        _this = this;
      lastTime = 0;
      changesSpacedEnough = function(time) {
        var result;
        result = time - lastTime >= 1000;
        lastTime = time;
        return result;
      };
      return function(action) {
        var time;
        time = new Date();
        if (!changesSpacedEnough(time.getTime())) {
          return;
        }
        return _this.pathChanged(path, action);
      };
    };

    Watcher.prototype.pathChanged = function(path, action) {
      var promise,
        _this = this;
      promise = this.promise.then(function() {
        return puts(cyan("" + (inverse(" " + (action.toUpperCase()) + "D ")) + " " + path));
      });
      switch (path) {
        case Neat.resolve('Watchfile'):
        case Neat.resolve('.watchignore'):
          promise = promise.then(this.dispose).then(this.init);
          break;
        default:
          this.plugins.each(function(name, plugin) {
            var p;
            if (plugin.match(path)) {
              p = plugin.pathChanged(path, action);
              promise = promise.then(function() {
                _this.activePlugin = plugin;
                return puts(cyan("" + (inverse(" " + (name.toUpperCase()) + " ")) + " " + path));
              });
              return promise = promise.then(p);
            }
          });
      }
      if (promise != null) {
        return this.promise = promise;
      }
    };

    Watcher.prototype.enqueue = function(promise) {
      return this.promise = this.promise.then(promise);
    };

    Watcher.prototype.loadWatchfile = function() {
      var defer;
      defer = Q.defer();
      fs.readFile(Neat.resolve('Watchfile'), function(err, file) {
        if (err != null) {
          return defer.reject(err);
        }
        return defer.resolve(file.toString());
      });
      return defer.promise;
    };

    Watcher.prototype.initializePlugins = function() {
      var k, plugin;
      return Q.all((function() {
        var _ref1, _results;
        _ref1 = this.plugins;
        _results = [];
        for (k in _ref1) {
          plugin = _ref1[k];
          _results.push(plugin.init(this));
        }
        return _results;
      }).call(this));
    };

    Watcher.prototype.loadWatchignore = function() {
      var defer;
      defer = Q.defer();
      fs.readFile(Neat.resolve('.watchignore'), function(err, file) {
        if (err != null) {
          return defer.reject(err);
        }
        return defer.resolve(file.toString().split('\n').select(function(s) {
          return s.length > 0;
        }));
      });
      return defer.promise;
    };

    Watcher.prototype.indexPaths = function() {
      var defer, ignoredPaths, search, watchedPaths,
        _this = this;
      defer = Q.defer();
      watchedPaths = [];
      ignoredPaths = [];
      search = function(root) {
        return function(cb) {
          if (_this.isIgnored(root)) {
            return ignoredPaths.push(root) && (typeof cb === "function" ? cb() : void 0);
          }
          watchedPaths.push(root);
          return fs.lstat(root, function(err, stats) {
            if (stats.isDirectory()) {
              return fs.readdir(root, function(err, paths) {
                var p;
                return parallel((function() {
                  var _i, _len, _results;
                  _results = [];
                  for (_i = 0, _len = paths.length; _i < _len; _i++) {
                    p = paths[_i];
                    _results.push(search(path.resolve(root, p)));
                  }
                  return _results;
                })(), cb);
              });
            } else {
              return typeof cb === "function" ? cb() : void 0;
            }
          });
        };
      };
      search(Neat.root)(function() {
        return defer.resolve({
          watchedPaths: watchedPaths,
          ignoredPaths: ignoredPaths
        });
      });
      return defer.promise;
    };

    Watcher.prototype.watchDirectory = function(directory, watcher) {
      var _this = this;
      return this.watches[directory] = fs.watch(directory, function(action) {
        return _this.enqueue(Q.fcall(function() {
          var file, files, stats, w, _i, _len, _results;
          files = fs.readdirSync(directory);
          _results = [];
          for (_i = 0, _len = files.length; _i < _len; _i++) {
            file = files[_i];
            file = path.resolve(directory, file);
            if (!(file in _this.watches || _this.isIgnored(file))) {
              stats = fs.lstatSync(file);
              if (stats.isDirectory()) {
                _this.watchDirectory(file, watcher);
              } else {
                w = watcher(file);
                w('create', file);
                _this.rewatch(file, w);
              }
              _results.push(_this.watchedPaths.push(file));
            } else {
              _results.push(void 0);
            }
          }
          return _results;
        }, 0));
      });
    };

    Watcher.prototype.rewatch = function(file, watcher) {
      var _this = this;
      if (this.watches[file] != null) {
        this.watches[file].close();
      }
      return this.watches[file] = fs.watch(file, function(action) {
        var exist;
        exist = existsSync(file);
        if (!exist) {
          action = 'delete';
        }
        watcher(action, file);
        if (exist) {
          return _this.rewatch(file, watcher);
        } else {
          return _this.watchedPaths;
        }
      });
    };

    Watcher.prototype.registerWatchers = function() {
      var _this = this;
      return this.watchedPaths.forEach(function(path) {
        var stats;
        stats = fs.lstatSync(path);
        if (stats.isDirectory()) {
          return _this.watchDirectory(path, _this.watcher);
        } else {
          return _this.rewatch(path, _this.watcher(path));
        }
      });
    };

    Watcher.prototype.evaluateWatchfile = function(watchfile) {
      var currentGroup, currentWatcher, group, plugins, watch, watcher,
        _this = this;
      this.plugins = {};
      currentWatcher = null;
      currentGroup = null;
      plugins = Neat.require('watchers');
      watcher = function(name, options, block) {
        var _base, _ref1, _ref2;
        if (typeof options === 'function') {
          _ref1 = [block, options], options = _ref1[0], block = _ref1[1];
        }
        options || (options = {});
        if (name in plugins) {
          if ((_ref2 = (_base = _this.plugins)[name]) == null) {
            _base[name] = new plugins[name](options, _this);
          }
          currentWatcher = name;
          return block.call();
        } else {
          return warn(yellow("Unregistered plugin " + name));
        }
      };
      group = function(name, block) {
        currentGroup = name;
        return block.call();
      };
      watch = function(pattern, options, block) {
        var re, _ref1;
        if (typeof options === 'function') {
          _ref1 = [block, options], options = _ref1[0], block = _ref1[1];
        }
        options || (options = {});
        re = RegExp("" + Neat.root + "/" + pattern);
        return _this.plugins[currentWatcher].watch(new Watch(re, options, block));
      };
      return eval(compile(watchfile, {
        bare: true
      }));
    };

    Watcher.prototype.toString = function() {
      return "[object Watcher]";
    };

    return Watcher;

  })();

  module.exports = Watcher;

}).call(this);
