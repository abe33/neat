(function() {
  var Neat, asyncErrorTrap, changesSpacedEnough, compiling, error, fs, green, info, lastTime, neatTask, path, recursiveWatch, red, run, _, _ref, _ref1;

  fs = require('fs');

  path = require('path');

  Neat = require('../neat');

  _ref = Neat.require('utils/commands'), run = _ref.run, neatTask = _ref.neatTask, asyncErrorTrap = _ref.asyncErrorTrap;

  _ref1 = Neat.require('utils/logs'), error = _ref1.error, info = _ref1.info, green = _ref1.green, red = _ref1.red;

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

  compiling = false;

  exports.watch = neatTask({
    name: 'watch',
    description: _('neat.tasks.watch.description'),
    action: function(callback) {
      var recompileAfter, watcher;
      recompileAfter = false;
      watcher = function(e, f) {
        if (compiling && changesSpacedEnough(new Date().getTime())) {
          recompileAfter = true;
          return;
        }
        compiling = true;
        return Neat.task('compile')(function() {
          compiling = false;
          if (recompileAfter) {
            recompileAfter = false;
            return watcher(e, f);
          }
        });
      };
      return recursiveWatch(path.resolve('.', 'src'), watcher);
    }
  });

  exports['watch:test'] = neatTask({
    name: 'watch:test',
    description: _('neat.tasks.watch_test.description'),
    action: function(callback) {
      var retestAfter, watcher;
      retestAfter = false;
      watcher = function(e, f) {
        var testing;
        if (testing && changesSpacedEnough(new Date().getTime())) {
          retestAfter = true;
          return;
        }
        testing = true;
        return Neat.task('test')(function() {
          testing = false;
          if (retestAfter) {
            retestAfter = false;
            return watcher(e, f);
          }
        });
      };
      recursiveWatch(path.resolve('.', 'src'), watcher);
      return recursiveWatch(path.resolve('.', 'test'), watcher);
    }
  });

}).call(this);
