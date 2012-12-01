(function() {
  var JASMINE, Neat, error, fs, paths, puts, queue, red, run, yellow, _ref;

  fs = require('fs');

  Neat = require('../../../neat');

  queue = require('../../../async').queue;

  run = require('../../../utils/commands').run;

  _ref = require('../../../utils/logs'), error = _ref.error, red = _ref.red, yellow = _ref.yellow, puts = _ref.puts;

  paths = Neat.paths.map(function(p) {
    return "" + p + "/node_modules/.bin/jasmine-node";
  });

  paths = paths.filter(function(p) {
    return fs.existsSync(p);
  });

  JASMINE = paths[0];

  module.exports = function(config) {
    return config.engines.tests.jasmine = function(name, test, callback) {
      var args;
      if (!fs.existsSync(JASMINE)) {
        error("" + (red("Can't find jasmine-node module")) + "\n\nRun " + (yellow('neat install')) + " to install the dependencies.");
        return typeof callback === "function" ? callback() : void 0;
      }
      args = ['.', '--color', '--coffee', '--test-dir'];
      puts(yellow("" + (name.capitalize()) + " tests:"));
      return run(JASMINE, args.concat("" + Neat.root + "/" + test), callback);
    };
  };

}).call(this);
