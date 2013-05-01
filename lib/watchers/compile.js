(function() {
  var CLIWatchPlugin, Compile, Neat, Q, commands, _ref,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Q = require('q');

  Neat = require('../neat');

  CLIWatchPlugin = Neat.require('tasks/watch/cli_watch_plugin');

  commands = Neat.require('utils/commands');

  Compile = (function(_super) {
    __extends(Compile, _super);

    function Compile() {
      _ref = Compile.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    Compile.prototype.pathChanged = function(path, action) {
      var _this = this;

      return function() {
        _this.deferred = Q.defer();
        _this.process = commands.run('cake', ['build'], function(status) {
          return _this.deferred.resolve(status);
        });
        return _this.deferred.promise;
      };
    };

    return Compile;

  })(CLIWatchPlugin);

  module.exports.compile = Compile;

}).call(this);
