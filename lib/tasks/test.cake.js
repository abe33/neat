(function() {
  var Neat, beforeTests, error, functional, green, growly, handleTestResult, index, info, integration, namespace, neatTask, path, puts, queue, red, runTests, unit, yellow, _, _ref;

  path = require('path');

  growly = require('growly');

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
          return f(n, d, function(status, result) {
            statuses.push([status, result]);
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
        var a, o, result, status, _i, _len;
        status = statuses.some(function(n) {
          return n[0] === 1;
        }) ? 1 : 0;
        result = {};
        for (_i = 0, _len = statuses.length; _i < _len; _i++) {
          a = statuses[_i];
          o = a[1];
          if (o != null) {
            o.each(function(k, v) {
              if (result[k]) {
                return result[k] += v;
              } else {
                return result[k] = v;
              }
            });
          }
        }
        return typeof callback === "function" ? callback(status, result) : void 0;
      });
    };
  };

  handleTestResult = function(status, result) {
    var k, v;
    if (status === 0) {
      info(green(_('neat.tasks.test.tests_done')));
      return growly.notify("" + (_('neat.tasks.test.tests_done')) + "\n" + (((function() {
        var _results;
        _results = [];
        for (k in result) {
          v = result[k];
          _results.push("" + v + " " + k);
        }
        return _results;
      })()).join(', ')));
    } else {
      error(red(_('neat.tasks.test.tests_failed')));
      return growly.notify("" + (_('neat.tasks.test.tests_failed')) + "\n" + (((function() {
        var _results;
        _results = [];
        for (k in result) {
          v = result[k];
          _results.push("" + v + " " + k);
        }
        return _results;
      })()).join(', ')));
    }
  };

  index = neatTask({
    name: 'test',
    description: _('neat.tasks.test.description'),
    environment: 'test',
    action: beforeTests(function(callback) {
      return runTests('unit', 'test/units')(function(statusUnit, resultUnit) {
        return runTests('functional', 'test/functionals')(function(statusFunctional, resultFunctional) {
          return runTests('integration', 'test/integrations')(function(statusIntegration, resultIntegration) {
            var k, o, result, results, status, statuses, v, _i, _len;
            statuses = [statusUnit, statusFunctional, statusIntegration];
            status = statuses.some(function(n) {
              return n === 1;
            }) ? 1 : 0;
            results = [resultUnit, resultFunctional, resultIntegration];
            result = {};
            for (_i = 0, _len = results.length; _i < _len; _i++) {
              o = results[_i];
              if (o != null) {
                for (k in o) {
                  v = o[k];
                  if (result[k] != null) {
                    result[k] += v;
                  } else {
                    result[k] = v;
                  }
                }
              }
            }
            handleTestResult(status, result);
            return typeof callback === "function" ? callback(status) : void 0;
          });
        });
      });
    })
  });

  unit = neatTask({
    name: 'test:unit',
    description: _('neat.tasks.test.unit_description'),
    environment: 'test',
    action: beforeTests(function(callback) {
      return runTests('unit', 'test/units')(function(status, result) {
        handleTestResult(status, result);
        return typeof callback === "function" ? callback(status) : void 0;
      });
    })
  });

  functional = neatTask({
    name: 'test:functional',
    description: _('neat.tasks.test.functional_description'),
    environment: 'test',
    action: beforeTests(function(callback) {
      return runTests('functional', 'test/functionals')(function(status, result) {
        handleTestResult(status, result);
        return typeof callback === "function" ? callback(status) : void 0;
      });
    })
  });

  integration = neatTask({
    name: 'test:integration',
    description: _('neat.tasks.test.integration_description'),
    environment: 'test',
    action: beforeTests(function(callback) {
      return runTests('integration', 'test/integrations')(function(status, result) {
        handleTestResult(status, result);
        return typeof callback === "function" ? callback(status) : void 0;
      });
    })
  });

  module.exports = namespace('test', {
    index: index,
    unit: unit,
    functional: functional,
    integration: integration
  });

}).call(this);
