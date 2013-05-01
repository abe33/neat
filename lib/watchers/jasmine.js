(function() {
  var CLIWatchPlugin, Jasmine, Neat, Q, commands, error, green, info, inverse, magenta, puts, red, yellow, _ref, _ref1,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Q = require('q');

  Neat = require('../neat');

  CLIWatchPlugin = Neat.require('tasks/watch/cli_watch_plugin');

  commands = Neat.require('utils/commands');

  _ref = Neat.require('utils/logs'), puts = _ref.puts, magenta = _ref.magenta, yellow = _ref.yellow, info = _ref.info, error = _ref.error, red = _ref.red, green = _ref.green, inverse = _ref.inverse;

  Jasmine = (function(_super) {
    __extends(Jasmine, _super);

    function Jasmine() {
      this.runAll = __bind(this.runAll, this);      _ref1 = Jasmine.__super__.constructor.apply(this, arguments);
      return _ref1;
    }

    Jasmine.prototype.pathChanged = function(path, action) {
      var _this = this;

      return function() {
        return _this.outputPathsFor(path).then(function(paths) {
          return _this.runJasmine(path, paths.flatten());
        });
      };
    };

    Jasmine.prototype.handleStatus = function(status) {
      var _ref2, _ref3;

      if (status === 0) {
        if ((_ref2 = this.watcher) != null) {
          _ref2.notifier.notify({
            success: true,
            title: 'Jasmine',
            message: "All specs passed"
          });
        }
        info(green('success'));
      } else {
        if ((_ref3 = this.watcher) != null) {
          _ref3.notifier.notify({
            success: false,
            title: 'Jasmine',
            message: "Some specs failed"
          });
        }
        error(red('failure'));
      }
      return this.deferred.resolve(status);
    };

    Jasmine.prototype.runAll = function() {
      var args, jasmine,
        _this = this;

      this.deferred = Q.defer();
      puts(yellow("run jasmine-node --coffee " + (Neat.resolve('test'))));
      jasmine = Neat.resolve('node_modules/.bin/jasmine-node');
      args = ['--coffee', Neat.resolve('test')];
      this.process = commands.run(jasmine, args, function(status) {
        return _this.handleStatus(status);
      });
      return this.deferred.promise;
    };

    Jasmine.prototype.runJasmine = function(path, paths) {
      var jasmine,
        _this = this;

      this.deferred = Q.defer();
      if (paths.length > 0) {
        puts(yellow("run jasmine-node --coffee " + (paths.join(' '))));
        jasmine = Neat.resolve('node_modules/.bin/jasmine-node');
        this.process = commands.run(jasmine, ['--coffee'].concat(paths), function(status) {
          return _this.handleStatus(status);
        });
      } else {
        puts(yellow("" + (inverse(' NO SPEC ')) + " No specs can be found for " + path));
        this.deferred.resolve(0);
      }
      return this.deferred.promise;
    };

    return Jasmine;

  })(CLIWatchPlugin);

  module.exports.jasmine = Jasmine;

}).call(this);
