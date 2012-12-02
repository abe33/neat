(function() {
  var Neat, beforeTests, error, functional, green, index, info, namespace, neatTask, path, puts, queue, red, runTests, unit, yellow, _, _ref;

  path = require('path');

  Neat = require('../neat');

  queue = Neat.require('async').queue;

  neatTask = Neat.require('utils/commands').neatTask;

  namespace = Neat.require('utils/exports').namespace;

  _ref = Neat.require('utils/logs'), error = _ref.error, info = _ref.info, green = _ref.green, red = _ref.red, yellow = _ref.yellow, puts = _ref.puts;

  _ = Neat.i18n.getHelper();

  beforeTests = function(test) {
    return function(callback) {
      return Neat.task('compile')(function(status) {
        if (status === 0) {
          return test(callback);
        } else {
          return typeof callback === "function" ? callback(1) : void 0;
        }
      });
    };
  };

  runTests = function(name, dir) {
    return function(callback) {
      var actions, f, k, statuses, test;
      statuses = [];
      test = function(k, f, n, d) {
        return function(callback) {
          return f(n, d, function(status) {
            statuses.push(status);
            return typeof callback === "function" ? callback(status) : void 0;
          });
        };
      };
      actions = (function() {
        var _ref1, _results;
        _ref1 = Neat.config.engines.tests;
        _results = [];
        for (k in _ref1) {
          f = _ref1[k];
          _results.push(test(k, f, name, dir));
        }
        return _results;
      })();
      return queue(actions, function() {
        var status;
        status = statuses.some(function(n) {
          return n === 1;
        }) ? 1 : 0;
        return typeof callback === "function" ? callback(status) : void 0;
      });
    };
  };

  index = neatTask({
    name: 'test',
    description: _('neat.tasks.test.description'),
    environment: 'test',
    action: beforeTests(function(callback) {
      return runTests('unit', 'test/units')(function(statusUnit) {
        return runTests('functional', 'test/functionals')(function(statusFunctional) {
          var status, statuses;
          statuses = [statusUnit, statusFunctional];
          status = statuses.some(function(n) {
            return n === 1;
          }) ? 1 : 0;
          if (status === 0) {
            info(green(_('neat.tasks.test.tests_done')));
          } else {
            error(red(_('neat.tasks.test.tests_failed')));
          }
          return typeof callback === "function" ? callback(status) : void 0;
        });
      });
    })
  });

  unit = neatTask({
    name: 'test:unit',
    description: _('neat.tasks.test.unit_description'),
    environment: 'test',
    action: beforeTests(function(callback) {
      return runTests('unit', 'test/units')(function(status) {
        if (status === 0) {
          info(green(_('neat.tasks.test.tests_done')));
        } else {
          error(red(_('neat.tasks.test.tests_failed')));
        }
        return typeof callback === "function" ? callback(status) : void 0;
      });
    })
  });

  functional = neatTask({
    name: 'test:functional',
    description: _('neat.tasks.test.functional_description'),
    environment: 'test',
    action: beforeTests(function(callback) {
      return runTests('functional', 'test/functionals')(function(status) {
        if (status === 0) {
          info(green(_('neat.tasks.test.tests_done')));
        } else {
          error(red(_('neat.tasks.test.tests_failed')));
        }
        return typeof callback === "function" ? callback(status) : void 0;
      });
    })
  });

  module.exports = namespace('test', {
    index: index,
    unit: unit,
    functional: functional
  });

}).call(this);
