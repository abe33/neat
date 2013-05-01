(function() {
  var COFFEE_LINT, Neat, asyncErrorTrap, error, existsSync, find, findSiblingFile, fs, green, info, missing, neatTask, path, print, puts, queue, red, run, yellow, _, _ref, _ref1, _ref2;

  fs = require('fs');

  path = require('path');

  Neat = require('../neat');

  _ref = Neat.require('utils/commands'), run = _ref.run, neatTask = _ref.neatTask, asyncErrorTrap = _ref.asyncErrorTrap;

  _ref1 = Neat.require('utils/logs'), error = _ref1.error, info = _ref1.info, green = _ref1.green, red = _ref1.red, puts = _ref1.puts, print = _ref1.print, yellow = _ref1.yellow, missing = _ref1.missing;

  _ref2 = Neat.require('utils/files'), find = _ref2.find, findSiblingFile = _ref2.findSiblingFile;

  queue = Neat.require('async').queue;

  existsSync = fs.existsSync || path.existsSync;

  _ = Neat.i18n.getHelper();

  COFFEE_LINT = "" + Neat.neatRoot + "/node_modules/.bin/coffeelint";

  exports['lint'] = neatTask({
    name: 'lint',
    description: _('neat.tasks.lint.description'),
    environment: 'default',
    action: function(callback) {
      var dir, err, paths;

      if (!existsSync(COFFEE_LINT)) {
        error(_('neat.errors.missing_module', {
          missing: missing('coffeelint')
        }));
        return typeof callback === "function" ? callback() : void 0;
      }
      path = __filename;
      paths = Neat.paths;
      dir = 'config';
      err = function() {
        return typeof callback === "function" ? callback(1) : void 0;
      };
      return findSiblingFile(path, paths, dir, 'json', asyncErrorTrap(err, function(conf, p) {
        var allerrors, allfiles, errors, failed, files, lint, linted;

        if (conf == null) {
          error(missing("config/tasks/lint.json"));
          return typeof callback === "function" ? callback(1) : void 0;
        }
        errors = [];
        allfiles = 0;
        linted = 0;
        failed = 0;
        allerrors = 0;
        lint = function(file) {
          return function(callback) {
            var logs, opts, params;

            allfiles += 1;
            params = ["-f", conf, file];
            logs = [];
            opts = {
              stdout: function(data) {
                return logs.push(function() {
                  return print(data);
                });
              },
              stderr: function(data) {
                return logs.push(function() {
                  return print(data);
                });
              }
            };
            return run(COFFEE_LINT, params, opts, function(status) {
              if (status === 0) {
                print(green('.'));
                linted += 1;
              } else {
                print(red('F'));
                failed += 1;
                errors.push(function() {
                  var log, _i, _len, _results;

                  puts(red(_('neat.tasks.lint.lint_error', {
                    file: file.replace("" + Neat.root + "/", '')
                  }), 3));
                  allerrors += logs.length;
                  _results = [];
                  for (_i = 0, _len = logs.length; _i < _len; _i++) {
                    log = logs[_i];
                    _results.push(log());
                  }
                  return _results;
                });
              }
              return typeof callback === "function" ? callback() : void 0;
            });
          };
        };
        paths = ["" + Neat.root + "/src", "" + Neat.root + "/test"];
        return files = find('coffee', paths, function(err, files) {
          var file;

          return queue((function() {
            var _i, _len, _results;

            _results = [];
            for (_i = 0, _len = files.length; _i < _len; _i++) {
              file = files[_i];
              _results.push(lint(file));
            }
            return _results;
          })(), function() {
            var _i, _len;

            puts('');
            if (errors.length === 0) {
              info(green(_('neat.tasks.lint.files_linted', {
                files: allfiles
              })));
              return typeof callback === "function" ? callback(0) : void 0;
            } else {
              for (_i = 0, _len = errors.length; _i < _len; _i++) {
                error = errors[_i];
                error();
              }
              puts(("\n                  " + allfiles + " files,                  " + (green("" + linted + " linted")) + ",                  " + (red("" + failed + " failed")) + ",                  " + (red("" + allerrors + " error" + (allerrors > 0 ? 's' : ''))) + "                 ").squeeze());
              return typeof callback === "function" ? callback(1) : void 0;
            }
          });
        });
      }));
    }
  });

}).call(this);
