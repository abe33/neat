(function() {
  var JASMINE, Neat, error, existsSync, fs, path, paths, print, puts, queue, red, run, yellow, _ref;

  fs = require('fs');

  path = require('path');

  print = require('util').print;

  Neat = require('../../../neat');

  queue = require('../../../async').queue;

  run = require('../../../utils/commands').run;

  _ref = require('../../../utils/logs'), error = _ref.error, red = _ref.red, yellow = _ref.yellow, puts = _ref.puts;

  existsSync = fs.existsSync || path.existsSync;

  paths = Neat.paths.map(function(p) {
    return "" + p + "/node_modules/.bin/jasmine-node";
  });

  paths = paths.filter(function(p) {
    return existsSync(p);
  });

  JASMINE = paths[0];

  module.exports = function(config) {
    return config.engines.tests.jasmine = function(name, test, callback) {
      var args, options, result, testDir;

      if (!existsSync(JASMINE)) {
        error("" + (red("Can't find jasmine-node module")) + "\n\nRun " + (yellow('neat install')) + " to install the dependencies.");
        return typeof callback === "function" ? callback() : void 0;
      }
      testDir = "" + Neat.root + "/" + test;
      if (!existsSync(testDir)) {
        return typeof callback === "function" ? callback(0) : void 0;
      }
      args = ['--color', '--coffee', '--test-dir'];
      result = null;
      options = {
        stdout: function(data) {
          var res, s;

          print(data.toString());
          s = data.toString();
          res = /(\d+) tests, (\d+) assertions, (\d+) failures/.exec(s);
          if (res) {
            return result = {
              tests: parseInt(res[1]),
              assertions: parseInt(res[2]),
              failures: parseInt(res[3])
            };
          }
        }
      };
      puts(yellow("" + (name.capitalize()) + " tests:"));
      return run(JASMINE, args.concat(testDir), options, function(status) {
        return callback(status, result);
      });
    };
  };

}).call(this);
