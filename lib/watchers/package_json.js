(function() {
  var CLIWatchPlugin, Neat, PackageJson, Q, commands, _ref,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Q = require('q');

  Neat = require('../neat');

  CLIWatchPlugin = Neat.require('tasks/watch/cli_watch_plugin');

  commands = Neat.require('utils/commands');

  PackageJson = (function(_super) {
    __extends(PackageJson, _super);

    function PackageJson() {
      _ref = PackageJson.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    PackageJson.prototype.pathChanged = function(path, action) {
      var _this = this;

      return function() {
        _this.deferred = Q.defer();
        _this.process = commands.run('neat', ['generate', 'package.json'], function(status) {
          var _ref1, _ref2;

          _this.deferred.resolve(status);
          if (status === 0) {
            return (_ref1 = _this.watcher) != null ? _ref1.notifier.notify({
              success: true,
              title: 'package.json',
              message: "File generated successfully"
            }) : void 0;
          } else {
            return (_ref2 = _this.watcher) != null ? _ref2.notifier.notify({
              success: false,
              title: 'package.json',
              message: "File generation failed"
            }) : void 0;
          }
        });
        return _this.deferred.promise;
      };
    };

    return PackageJson;

  })(CLIWatchPlugin);

  module.exports.package_json = PackageJson;

}).call(this);
