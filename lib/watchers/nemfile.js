(function() {
  var Neat, Nemfile, Q, WatchPlugin, commands, error, green, info, puts, red, _ref,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Q = require('q');

  Neat = require('../neat');

  WatchPlugin = Neat.require('tasks/watch/watch_plugin');

  commands = Neat.require('utils/commands');

  _ref = Neat.require('utils/logs'), puts = _ref.puts, info = _ref.info, error = _ref.error, red = _ref.red, green = _ref.green;

  Nemfile = (function(_super) {

    __extends(Nemfile, _super);

    function Nemfile() {
      return Nemfile.__super__.constructor.apply(this, arguments);
    }

    Nemfile.prototype.pathChanged = function(path, action) {
      var _this = this;
      return function() {
        _this.deferred = Q.defer();
        _this.process = commands.run('neat', ['install'], function(status) {
          return _this.deferred.resolve(status);
        });
        return _this.deferred.promise;
      };
    };

    Nemfile.prototype.kill = function(signal) {
      this.process.kill(signal);
      return this.deferred.resolve(1);
    };

    return Nemfile;

  })(WatchPlugin);

  module.exports.nemfile = Nemfile;

}).call(this);
