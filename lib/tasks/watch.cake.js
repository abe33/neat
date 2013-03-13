(function() {
  var Neat, asyncErrorTrap, changesSpacedEnough, cyan, error, fs, green, info, lastTime, neatTask, path, puts, recursiveWatch, red, run, watchTaskGen, _, _ref, _ref1,
    __slice = [].slice;

  fs = require('fs');

  path = require('path');

  Neat = require('../neat');

  _ref = Neat.require('utils/commands'), run = _ref.run, neatTask = _ref.neatTask, asyncErrorTrap = _ref.asyncErrorTrap;

  _ref1 = Neat.require('utils/logs'), error = _ref1.error, puts = _ref1.puts, info = _ref1.info, green = _ref1.green, red = _ref1.red, cyan = _ref1.cyan;

  _ = Neat.i18n.getHelper();

  lastTime = 0;

  changesSpacedEnough = function(time) {
    var result;
    result = lastTime - time > 0.0000000001;
    lastTime = time;
    return result;
  };

  recursiveWatch = function(dir, watcher) {
    fs.watch(dir, watcher);
    return fs.readdir(dir, asyncErrorTrap(function(files) {
      return files.forEach(function(file) {
        file = path.resolve(dir, file);
        return fs.lstat(file, asyncErrorTrap(function(stats) {
          if (stats.isDirectory()) {
            return recursiveWatch(file, watcher);
          }
        }));
      });
    }));
  };

  watchTaskGen = function() {
    var description, name, rerunAfter, task, watches;
    name = arguments[0], task = arguments[1], description = arguments[2], watches = 4 <= arguments.length ? __slice.call(arguments, 3) : [];
    watches = watches.flatten();
    rerunAfter = false;
    return exports[name] = neatTask({
      name: name,
      description: description,
      action: function(callback) {
        var w, watcher, _i, _len, _results;
        rerunAfter = false;
        watcher = function(e, f) {
          var testing;
          if (testing && changesSpacedEnough(new Date().getTime())) {
            rerunAfter = true;
            return;
          }
          puts(cyan("" + (f || '<file name not provided>') + " " + e + "d"));
          testing = true;
          return run('cake', [task], function(status) {
            testing = false;
            if (rerunAfter) {
              rerunAfter = false;
              return watcher(e, f);
            }
          });
        };
        _results = [];
        for (_i = 0, _len = watches.length; _i < _len; _i++) {
          w = watches[_i];
          _results.push(recursiveWatch(path.resolve('.', w), watcher));
        }
        return _results;
      }
    });
  };

  watchTaskGen('watch', 'compile', _('neat.tasks.watch.description'), 'src');

  watchTaskGen('watch:test', 'test', _('neat.tasks.watch_test.description'), 'src', 'test/units', 'test/functionals');

  watchTaskGen('watch:test:unit', 'test:unit', _('neat.tasks.watch_test.description'), 'src', 'test/units');

  watchTaskGen('watch:test:functional', 'test:functional', _('neat.tasks.watch_test.description'), 'src', 'test/functionals');

  watchTaskGen('watch:test:integration', 'test:integration', _('neat.tasks.watch_test.description'), 'src', 'test/integrations');

}).call(this);
