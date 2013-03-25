(function() {
  var ACTIONS_MAP, ALL_FILES, IGNORE_LIST, Neat, Q, WATCHERS, WATCHES, asyncErrorTrap, compile, cyan, error, existsSync, fs, green, indexFiles, info, isIgnored, n, neatTask, parallel, path, promise, puts, recursiveWatch, red, rewatch, run, watchDirectory, watcher, yellow, _ref, _ref1,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  fs = require('fs');

  path = require('path');

  Q = require('q');

  Neat = require('../neat');

  compile = require('coffee-script').compile;

  _ref = Neat.require('utils/commands'), run = _ref.run, neatTask = _ref.neatTask, asyncErrorTrap = _ref.asyncErrorTrap;

  _ref1 = Neat.require('utils/logs'), error = _ref1.error, info = _ref1.info, green = _ref1.green, red = _ref1.red, yellow = _ref1.yellow, cyan = _ref1.cyan, puts = _ref1.puts;

  parallel = Neat.require('async').parallel;

  existsSync = fs.existsSync || path.existsSync;

  WATCHERS = Neat.require('watchers');

  ALL_FILES = null;

  IGNORE_LIST = null;

  ACTIONS_MAP = {};

  WATCHES = {};

  isIgnored = function(file) {
    return IGNORE_LIST.some(function(i) {
      return RegExp("" + Neat.root + "/" + i).test(file);
    });
  };

  watchDirectory = function(directory, watcher) {
    return fs.watch(directory, function(action) {
      return setTimeout(function() {
        var file, files, stats, w, _i, _len, _results;
        files = fs.readdirSync(directory);
        _results = [];
        for (_i = 0, _len = files.length; _i < _len; _i++) {
          file = files[_i];
          file = path.resolve(directory, file);
          if (!(__indexOf.call(ALL_FILES, file) >= 0 || isIgnored(file))) {
            stats = fs.lstatSync(file);
            if (stats.isDirectory()) {
              watchDirectory(file, watcher);
            } else {
              w = watcher(file);
              w('create', file);
              rewatch(file, w);
            }
            _results.push(ALL_FILES.push(file));
          } else {
            _results.push(void 0);
          }
        }
        return _results;
      }, 0);
    });
  };

  rewatch = function(file, watcher) {
    if (WATCHES[file] != null) {
      WATCHES[file].close();
    }
    return WATCHES[file] = fs.watch(file, function(action) {
      var exist;
      exist = existsSync(file);
      if (!exist) {
        action = 'delete';
      }
      watcher(action, file);
      if (exist) {
        return rewatch(file, watcher);
      } else {
        return ALL_FILES;
      }
    });
  };

  recursiveWatch = function(dir, watcher) {
    if (isIgnored(dir)) {
      return;
    }
    watchDirectory(dir, watcher);
    return fs.readdir(dir, asyncErrorTrap(function(files) {
      return files.forEach(function(file) {
        file = path.resolve(dir, file);
        if (isIgnored(file)) {
          return;
        }
        return fs.lstat(file, asyncErrorTrap(function(stats) {
          if (stats.isDirectory()) {
            recursiveWatch(file, watcher);
            return watchDirectory(file, watcher);
          } else {
            return rewatch(file, watcher(file));
          }
        }));
      });
    }));
  };

  indexFiles = function(callback) {
    var allFiles, search;
    allFiles = [];
    search = function(root) {
      return function(cb) {
        if (isIgnored(root)) {
          return typeof cb === "function" ? cb() : void 0;
        }
        allFiles.push(root);
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
    return search(Neat.root)(function() {
      return callback(allFiles);
    });
  };

  n = 0;

  promise = null;

  watcher = function(file) {
    var changesSpacedEnough, id, lastTime, rerunAfter;
    id = n;
    n += 1;
    lastTime = 0;
    rerunAfter = false;
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
      puts(cyan("" + (id.toString().right(4)) + " - " + time + " - " + file + " " + action + "d"));
      ACTIONS_MAP.each(function(watcher, watches) {
        var block, match, options, p, pattern, re, _i, _len, _ref2, _results;
        _results = [];
        for (_i = 0, _len = watches.length; _i < _len; _i++) {
          _ref2 = watches[_i], pattern = _ref2[0], re = _ref2[1], options = _ref2[2], block = _ref2[3];
          if (match = re.exec(file)) {
            p = WATCHERS[watcher].call(null, match, options, block);
            if (promise != null) {
              _results.push(promise = promise.then(p));
            } else {
              _results.push(promise = p());
            }
          } else {
            _results.push(void 0);
          }
        }
        return _results;
      });
      if (promise != null) {
        return promise.fail(function(err) {
          return error(red(err));
        });
      }
    };
  };

  exports['watch:new'] = neatTask({
    name: 'watch:new',
    description: 'Attempt to create a smarter watch task',
    environment: 'default',
    action: function(callback) {
      return fs.readFile("" + Neat.root + "/.watchignore", asyncErrorTrap(function(ignore) {
        IGNORE_LIST = ignore.toString().split('\n').select(function(s) {
          return s.length > 0;
        });
        return indexFiles(function(files) {
          ALL_FILES = files;
          return fs.readFile("" + Neat.root + "/Watchfile", asyncErrorTrap(function(file) {
            var currentGroup, currentWatcher, group, watch;
            recursiveWatch(Neat.root, watcher);
            puts(yellow("" + ALL_FILES.length + " files found in the project"));
            file = file.toString();
            currentWatcher = null;
            currentGroup = null;
            watcher = function(name, block) {
              ACTIONS_MAP[name] || (ACTIONS_MAP[name] = []);
              currentWatcher = name;
              return block.call();
            };
            group = function(name, block) {
              currentGroup = name;
              return block.call();
            };
            watch = function(pattern, options, block) {
              var re, _ref2;
              if (typeof options === 'function') {
                _ref2 = [block, options], options = _ref2[0], block = _ref2[1];
              }
              options || (options = {});
              re = RegExp("" + Neat.root + "/" + pattern);
              return ACTIONS_MAP[currentWatcher].push([pattern, re, options, block]);
            };
            return eval(compile(file, {
              bare: true
            }));
          }));
        });
      }));
    }
  });

}).call(this);
