(function() {
  var Lint, Neat, Q, WatchPlugin, commands, error, green, info, puts, red, _ref,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Q = require('q');

  Neat = require('../neat');

  WatchPlugin = Neat.require('tasks/watch/watch_plugin');

  commands = Neat.require('utils/commands');

  _ref = Neat.require('utils/logs'), puts = _ref.puts, info = _ref.info, error = _ref.error, red = _ref.red, green = _ref.green;

  Lint = (function(_super) {

    __extends(Lint, _super);

    function Lint() {
      return Lint.__super__.constructor.apply(this, arguments);
    }

    Lint.prototype.init = function(watcher) {
      if (this.options.runAllOnStart) {
        return this.runCakeLint();
      }
    };

    Lint.prototype.pathChanged = function(path, action) {
      var _this = this;
      return function() {
        return _this.outputPathsFor(path).then(function(paths) {
          return _this.runLint(paths.flatten());
        });
      };
    };

    Lint.prototype.runCakeLint = function(paths) {
      var _this = this;
      this.deferred = Q.defer();
      this.process = commands.run('cake', ['lint'], function(status) {
        return _this.deferred.resolve(status);
      });
      return this.deferred.promise;
    };

    Lint.prototype.runLint = function(paths) {
      var coffeelint,
        _this = this;
      this.deferred = Q.defer();
      coffeelint = Neat.resolve('node_modules/.bin/coffeelint');
      this.process = commands.run(coffeelint, paths, function(status) {
        if (status === 0) {
          info(green('success'));
        } else {
          error(red('failure'));
        }
        return _this.deferred.resolve(status);
      });
      return this.deferred.promise;
    };

    Lint.prototype.kill = function(signal) {
      this.process.kill(signal);
      return this.deferred.resolve(1);
    };

    return Lint;

  })(WatchPlugin);

  module.exports.lint = Lint;

}).call(this);
