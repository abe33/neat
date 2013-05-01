(function() {
  var Neat, asyncErrorTrap, bump, error, existsSync, fs, green, info, namespace, neatTask, path, puts, red, run, _, _ref, _ref1;

  fs = require('fs');

  path = require('path');

  Neat = require('../neat');

  namespace = Neat.require('utils/exports').namespace;

  _ref = Neat.require('utils/commands'), run = _ref.run, neatTask = _ref.neatTask, asyncErrorTrap = _ref.asyncErrorTrap;

  _ref1 = Neat.require('utils/logs'), error = _ref1.error, info = _ref1.info, green = _ref1.green, red = _ref1.red, puts = _ref1.puts;

  _ = Neat.i18n.getHelper();

  existsSync = fs.existsSync || path.existsSync;

  bump = function(majorBump, minorBump, buildBump, callback) {
    var err, newVersion, re, replaceVersion;

    if (majorBump == null) {
      majorBump = 0;
    }
    if (minorBump == null) {
      minorBump = 0;
    }
    if (buildBump == null) {
      buildBump = 1;
    }
    re = /("?version"?):\s*["']{1}(\d+)\.(\d+)\.(\d+)["']{1}/g;
    newVersion = null;
    replaceVersion = function(cb) {
      return function(err, data) {
        var replaceFunc;

        if (err != null) {
          return typeof cb === "function" ? cb(new Error(_('neat.tasks.bump.no_neat'))) : void 0;
        }
        replaceFunc = function(match, key, majv, minv, build) {
          build = parseInt(build) + buildBump;
          minv = parseInt(minv);
          if (minorBump !== 0) {
            build = 0;
            minv += minorBump;
          }
          majv = parseInt(majv);
          if (majorBump !== 0) {
            build = 0;
            minv = 0;
            majv += majorBump;
          }
          newVersion = "" + majv + "." + minv + "." + build;
          return "" + key + ": \"" + newVersion + "\"";
        };
        return typeof cb === "function" ? cb(null, data.toString().replace(re, replaceFunc)) : void 0;
      };
    };
    err = function() {
      return typeof callback === "function" ? callback(1) : void 0;
    };
    return fs.readFile(".neat", replaceVersion(asyncErrorTrap(err, function(res) {
      return fs.writeFile(".neat", res, asyncErrorTrap(err, function() {
        if (!existsSync('package.json')) {
          info(green(_('neat.tasks.bump.version_bumped', {
            version: newVersion
          })));
          return typeof callback === "function" ? callback(0) : void 0;
        }
        return fs.readFile("package.json", asyncErrorTrap(err, function(data) {
          var output;

          output = data.toString().replace(re, "\"version\": \"" + newVersion + "\"");
          return fs.writeFile("package.json", output, asyncErrorTrap(err, function() {
            info(green(_('neat.tasks.bump.version_bumped', {
              version: newVersion
            })));
            return typeof callback === "function" ? callback(0) : void 0;
          }));
        }));
      }));
    })));
  };

  module.exports = namespace('bump', {
    index: neatTask({
      name: 'bump',
      description: _('neat.tasks.bump.description'),
      action: function(callback) {
        return bump(0, 0, 1, callback);
      }
    }),
    minor: neatTask({
      name: 'bump:minor',
      description: _('neat.tasks.bump.minor_description'),
      action: function(callback) {
        return bump(0, 1, 0, callback);
      }
    }),
    major: neatTask({
      name: 'bump:major',
      description: _('neat.tasks.bump.major_description'),
      action: function(callback) {
        return bump(1, 0, 0, callback);
      }
    })
  });

}).call(this);
