(function() {
  var CLIWatchPlugin, Neat, Nemfile, Q, commands, error, green, info, puts, red, _ref, _ref1,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Q = require('q');

  Neat = require('../neat');

  CLIWatchPlugin = Neat.require('tasks/watch/cli_watch_plugin');

  commands = Neat.require('utils/commands');

  _ref = Neat.require('utils/logs'), puts = _ref.puts, info = _ref.info, error = _ref.error, red = _ref.red, green = _ref.green;

  Nemfile = (function(_super) {
    __extends(Nemfile, _super);

    function Nemfile() {
      _ref1 = Nemfile.__super__.constructor.apply(this, arguments);
      return _ref1;
    }

    Nemfile.prototype.pathChanged = function(path, action) {
      var _this = this;

      return function() {
        _this.deferred = Q.defer();
        _this.process = commands.run('neat', ['install'], function(status) {
          var _ref2, _ref3;

          _this.deferred.resolve(status);
          if (status === 0) {
            return (_ref2 = _this.watcher) != null ? _ref2.notifier.notify({
              success: true,
              title: 'npm',
              message: "Bundle complete"
            }) : void 0;
          } else {
            return (_ref3 = _this.watcher) != null ? _ref3.notifier.notify({
              success: false,
              title: 'npm',
              message: "Bundle failed"
            }) : void 0;
          }
        });
        return _this.deferred.promise;
      };
    };

    return Nemfile;

  })(CLIWatchPlugin);

  module.exports.nemfile = Nemfile;

}).call(this);
