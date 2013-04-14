(function() {
  var Compile, Neat, Q, WatchPlugin, commands,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Q = require('q');

  Neat = require('../neat');

  WatchPlugin = Neat.require('tasks/watch/watch_plugin');

  commands = Neat.require('utils/commands');

  Compile = (function(_super) {

    __extends(Compile, _super);

    function Compile() {
      return Compile.__super__.constructor.apply(this, arguments);
    }

    Compile.prototype.pathChanged = function(path, action) {
      var _this = this;
      return function() {
        _this.deferred = Q.defer();
        _this.process = commands.run('cake', ['compile'], function(status) {
          return _this.deferred.resolve(status);
        });
        return _this.deferred.promise;
      };
    };

    Compile.prototype.kill = function(signal) {
      this.process.kill(signal);
      return this.deferred.resolve(1);
    };

    return Compile;

  })(WatchPlugin);

  module.exports.compile = Compile;

}).call(this);
