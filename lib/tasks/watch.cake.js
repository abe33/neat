(function() {
  var Neat, asyncErrorTrap, compiling, error, fs, green, info, neatTask, path, recursiveWatch, red, run, _, _ref, _ref1;

  fs = require('fs');

  path = require('path');

  Neat = require('../neat');

  _ref = Neat.require('utils/commands'), run = _ref.run, neatTask = _ref.neatTask, asyncErrorTrap = _ref.asyncErrorTrap;

  _ref1 = Neat.require('utils/logs'), error = _ref1.error, info = _ref1.info, green = _ref1.green, red = _ref1.red;

  _ = Neat.i18n.getHelper();

  recursiveWatch = function(dir, watcher) {
    return fs.readdir(dir, asyncErrorTrap(function(files) {
      return files.forEach(function(file) {
        file = path.resolve(dir, file);
        return fs.lstat(file, asyncErrorTrap(function(stats) {
          if (stats.isDirectory()) {
            fs.watch(file, watcher);
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
        if (compiling) {
          recompileAfter = true;
          return;
        }
        compiling = true;
        return Neat.task('compile')(function() {
          compiling = false;
          if (recompileAfter) {
            return watcher(e, f);
          }
        });
      };
      return recursiveWatch(path.resolve('.', 'src'), watcher);
    }
  });

}).call(this);
