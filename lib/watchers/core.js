(function() {
  var Neat, Q, cyan, error, existsSync, fs, green, info, path, print, puts, red, run, runOptions, yellow, _ref;

  fs = require('fs');

  path = require('path');

  Q = require('q');

  Neat = require('../neat');

  _ref = Neat.require('utils/logs'), error = _ref.error, info = _ref.info, green = _ref.green, red = _ref.red, yellow = _ref.yellow, cyan = _ref.cyan, puts = _ref.puts, print = _ref.print;

  run = Neat.require('utils/commands').run;

  existsSync = fs.existsSync || path.existsSync;

  runOptions = {
    stdout: function(data) {
      return print(data.toString());
    },
    stderr: function(data) {
      return print(data.toString());
    }
  };

  module.exports.compile = function(match, options, block) {
    return function() {
      var defer;
      defer = Q.defer();
      puts(yellow("-- run cake compile"));
      run('cake', ['compile'], runOptions, function(status) {
        return defer.resolve(status);
      });
      return defer.promise;
    };
  };

  module.exports.coffee = function(match, options, block) {
    return function() {
      var command, defer, file, files, p;
      defer = Q.defer();
      p = match[0], file = match[1];
      if (block != null) {
        files = block(p, file);
      } else {
        file = file.split('/');
        file.pop();
        files = path.resolve(Neat.root, 'lib', file.join('/'));
      }
      files || (files = []);
      if (typeof files === 'string') {
        files = [files];
      }
      command = ['coffee', ['-co'].concat(files).concat(p)];
      puts(yellow("-- run " + (command.flatten().join(' '))));
      run.apply(null, command.concat(runOptions, function(status) {
        return defer.resolve(status);
      }));
      return defer.promise;
    };
  };

  module.exports.jasmine = function(match, options, block) {
    return function() {
      var command, defer, file, files, p;
      defer = Q.defer();
      p = match[0], file = match[1];
      if (block != null) {
        files = block(p, file);
      } else {
        file = file.split('/');
        file.pop();
        files = path.resolve(Neat.root, 'lib', file.join('/'));
      }
      files || (files = []);
      if (typeof files === 'string') {
        files = [files];
      }
      files = files.select(function(f) {
        return existsSync(f);
      });
      command = ['jasmine-node', ['--coffee', '--color'].concat(files)];
      if (!files.empty()) {
        puts(yellow("-- run " + (command.flatten().join(' '))));
        run.apply(null, command.concat(runOptions, function(status) {
          return defer.resolve(status);
        }));
      } else {
        puts(yellow("-- no tests to run for " + p));
        defer.resolve(0);
      }
      return defer.promise;
    };
  };

  module.exports.lint = function(match, options, block) {
    return function() {};
  };

  module.exports.manifest = function(match, options, block) {
    return function() {};
  };

}).call(this);
