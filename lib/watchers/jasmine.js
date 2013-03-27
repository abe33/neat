(function() {
  var Jasmine, Neat, Q, WatchPlugin, commands,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Q = require('q');

  Neat = require('../neat');

  WatchPlugin = Neat.require('tasks/watch/watch_plugin');

  commands = Neat.require('utils/commands');

  Jasmine = (function(_super) {

    __extends(Jasmine, _super);

    function Jasmine() {
      return Jasmine.__super__.constructor.apply(this, arguments);
    }

    Jasmine.prototype.pathChanged = function(path, action) {
      var _this = this;
      return function() {
        return _this.outputPathsFor(path).then(function(paths) {
          return _this.runJasmine(paths.flatten());
        });
      };
    };

    Jasmine.prototype.runJasmine = function(paths) {
      var defer, jasmine;
      defer = Q.defer();
      if (paths.length > 0) {
        jasmine = Neat.resolve('node_modules/.bin/jasmine-node');
        commands.run(jasmine, ['--coffee'].concat(paths), function(status) {
          return defer.resolve(status);
        });
      } else {
        defer.resolve(0);
      }
      return defer.promise;
    };

    return Jasmine;

  })(WatchPlugin);

  module.exports.jasmine = Jasmine;

}).call(this);
