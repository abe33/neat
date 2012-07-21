// Generated by CoffeeScript 1.3.3
(function() {
  var Neat, asyncErrorTrap, compiling, error, fs, green, info, neatTask, path, recursiveWatch, red, run, _ref, _ref1;

  fs = require('fs');

  path = require('path');

  Neat = require('../neat');

  _ref = require('../utils/commands'), run = _ref.run, neatTask = _ref.neatTask, asyncErrorTrap = _ref.asyncErrorTrap;

  _ref1 = require('../utils/logs'), error = _ref1.error, info = _ref1.info, green = _ref1.green, red = _ref1.red;

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
    description: 'Watches for changes in the src directory and run compile',
    action: function(callback) {
      recursiveWatch(path.resolve('.', 'src'), function(e, f) {
        if (compiling) {
          return;
        }
        compiling = true;
        return Neat.task('compile')(function() {
          return compiling = false;
        });
      });
      return typeof callback === "function" ? callback() : void 0;
    }
  });

}).call(this);