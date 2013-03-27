(function() {
  var Neat, PackageJson, Q, WatchPlugin, commands,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Q = require('q');

  Neat = require('../neat');

  WatchPlugin = Neat.require('tasks/watch/watch_plugin');

  commands = Neat.require('utils/commands');

  PackageJson = (function(_super) {

    __extends(PackageJson, _super);

    function PackageJson() {
      return PackageJson.__super__.constructor.apply(this, arguments);
    }

    PackageJson.prototype.pathChanged = function(path, action) {
      var _this = this;
      return function() {
        var defer;
        defer = Q.defer();
        commands.run('cake', ['package.json'], function(status) {
          return defer.resolve(status);
        });
        return defer.promise;
      };
    };

    return PackageJson;

  })(WatchPlugin);

  module.exports.package_json = PackageJson;

}).call(this);
