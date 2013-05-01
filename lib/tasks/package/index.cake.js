(function() {
  var Neat, Packager, asyncErrorTrap, deprecated, ensure, error, find, green, info, neatTask, op, parallel, puts, read, readFileSync, readFiles, red, rm, run, _, _ref, _ref1, _ref2;

  readFileSync = require('fs').readFileSync;

  Neat = require('../../neat');

  Packager = require('./packager');

  op = require('./operators');

  parallel = Neat.require('async').parallel;

  _ref = Neat.require('utils/commands'), run = _ref.run, neatTask = _ref.neatTask, asyncErrorTrap = _ref.asyncErrorTrap;

  _ref1 = Neat.require('utils/logs'), error = _ref1.error, info = _ref1.info, green = _ref1.green, red = _ref1.red, puts = _ref1.puts, error = _ref1.error;

  _ref2 = Neat.require('utils/files'), ensure = _ref2.ensure, rm = _ref2.rm, find = _ref2.find, readFiles = _ref2.readFiles;

  read = Neat.require('utils/cup').read;

  deprecated = Neat.require('utils/lib').deprecated;

  _ = Neat.i18n.getHelper();

  exports['package'] = neatTask({
    name: 'package',
    description: _('neat.tasks.package.description'),
    environment: 'default',
    action: function(callback) {
      var conf, dir, err, tmp, _ref3;

      deprecated('The old packager based compilation will no longer\
    be supported in future version of Neat. Use a Neatfile and The\
    cake build task instead.'.squeeze());
      _ref3 = Neat.config.tasks["package"], dir = _ref3.dir, conf = _ref3.conf, tmp = _ref3.tmp;
      err = function() {
        return typeof callback === "function" ? callback(1) : void 0;
      };
      return rm(dir, asyncErrorTrap(err, function() {
        return ensure(dir, asyncErrorTrap(err, function() {
          return find('cup', conf, asyncErrorTrap(err, function(files) {
            return readFiles(files, asyncErrorTrap(err, function(res) {
              var c, commands, p;

              commands = (function() {
                var _results;

                _results = [];
                for (p in res) {
                  c = res[p];
                  _results.push(Packager.asCommand(read(c), p));
                }
                return _results;
              })();
              return parallel(commands, function(res) {
                var failed, succeed;

                failed = 0;
                succeed = 0;
                res.forEach(function(status) {
                  if (status === 1) {
                    failed += 1;
                    return true;
                  } else {
                    succeed += 1;
                    return false;
                  }
                });
                if (failed > 0) {
                  error(red(_('neat.tasks.package.package_failed', {
                    succeed: succeed,
                    failed: failed
                  })));
                  return setTimeout((function() {
                    return typeof callback === "function" ? callback(1) : void 0;
                  }), 100);
                } else {
                  info(green(_('neat.tasks.package.packages_done', {
                    packages: res.length
                  })));
                  return setTimeout((function() {
                    return typeof callback === "function" ? callback(0) : void 0;
                  }), 100);
                }
              });
            }));
          }));
        }));
      }));
    }
  });

}).call(this);
