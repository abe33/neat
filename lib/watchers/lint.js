(function() {
  var CLIWatchPlugin, Lint, Neat, Q, commands, error, green, info, puts, red, _ref, _ref1,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Q = require('q');

  Neat = require('../neat');

  CLIWatchPlugin = Neat.require('tasks/watch/cli_watch_plugin');

  commands = Neat.require('utils/commands');

  _ref = Neat.require('utils/logs'), puts = _ref.puts, info = _ref.info, error = _ref.error, red = _ref.red, green = _ref.green;

  Lint = (function(_super) {
    __extends(Lint, _super);

    function Lint() {
      this.runAll = __bind(this.runAll, this);      _ref1 = Lint.__super__.constructor.apply(this, arguments);
      return _ref1;
    }

    Lint.prototype.init = function(watcher) {
      if (this.options.runAllOnStart) {
        return this.runAll();
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

    Lint.prototype.handleStatus = function(status) {
      var _ref2, _ref3;

      if (status === 1) {
        if ((_ref2 = this.watcher) != null) {
          _ref2.notifier.notify({
            success: false,
            title: 'Lint',
            message: "Lint failed"
          });
        }
      } else {
        if ((_ref3 = this.watcher) != null) {
          _ref3.notifier.notify({
            success: true,
            title: 'Lint',
            message: "Lint successful"
          });
        }
      }
      return this.deferred.resolve(status);
    };

    Lint.prototype.runAll = function(paths) {
      var _this = this;

      this.deferred = Q.defer();
      this.process = commands.run('cake', ['lint'], function(status) {
        return _this.handleStatus(status);
      });
      return this.deferred.promise;
    };

    Lint.prototype.runLint = function(paths) {
      var coffeelint,
        _this = this;

      this.deferred = Q.defer();
      coffeelint = Neat.resolve('node_modules/.bin/coffeelint');
      this.process = commands.run(coffeelint, paths, function(status) {
        return _this.handleStatus(status);
      });
      return this.deferred.promise;
    };

    return Lint;

  })(CLIWatchPlugin);

  module.exports.lint = Lint;

}).call(this);
