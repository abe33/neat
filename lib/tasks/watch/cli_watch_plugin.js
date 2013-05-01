(function() {
  var CLIWatchPlugin, Neat, WatchPlugin, _ref,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Neat = require('../../neat');

  WatchPlugin = Neat.require('tasks/watch/watch_plugin');

  CLIWatchPlugin = (function(_super) {
    __extends(CLIWatchPlugin, _super);

    function CLIWatchPlugin() {
      _ref = CLIWatchPlugin.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    CLIWatchPlugin.prototype.kill = function(signal) {
      this.deferred.resolve(1);
      return this.process.kill(signal);
    };

    CLIWatchPlugin.prototype.isPending = function() {
      return (this.deferred != null) && this.deferred.promise.isPending();
    };

    return CLIWatchPlugin;

  })(WatchPlugin);

  module.exports = CLIWatchPlugin;

}).call(this);
