(function() {
  var Jasmine, Neat, Q, WatchPlugin, commands, error, green, info, inverse, magenta, puts, red, yellow, _ref,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Q = require('q');

  Neat = require('../neat');

  WatchPlugin = Neat.require('tasks/watch/watch_plugin');

  commands = Neat.require('utils/commands');

  _ref = Neat.require('utils/logs'), puts = _ref.puts, magenta = _ref.magenta, yellow = _ref.yellow, info = _ref.info, error = _ref.error, red = _ref.red, green = _ref.green, inverse = _ref.inverse;

  Jasmine = (function(_super) {

    __extends(Jasmine, _super);

    function Jasmine() {
      return Jasmine.__super__.constructor.apply(this, arguments);
    }

    Jasmine.prototype.pathChanged = function(path, action) {
      var _this = this;
      return function() {
        return _this.outputPathsFor(path).then(function(paths) {
          return _this.runJasmine(path, paths.flatten());
        });
      };
    };

    Jasmine.prototype.runJasmine = function(path, paths) {
      var jasmine,
        _this = this;
      this.deferred = Q.defer();
      if (paths.length > 0) {
        puts(yellow("run jasmine-node --coffee " + (paths.join(' '))));
        jasmine = Neat.resolve('node_modules/.bin/jasmine-node');
        this.process = commands.run(jasmine, ['--coffee'].concat(paths), function(status) {
          if (status === 0) {
            info(green('success'));
          } else {
            error(red('failure'));
          }
          return _this.deferred.resolve(status);
        });
      } else {
        puts(yellow("" + (inverse(' NO SPEC ')) + " No specs can be found for " + path));
        this.deferred.resolve(0);
      }
      return this.deferred.promise;
    };

    Jasmine.prototype.kill = function(signal) {
      this.process.kill(signal);
      return this.deferred.resolve(1);
    };

    return Jasmine;

  })(WatchPlugin);

  module.exports.jasmine = Jasmine;

}).call(this);
