(function() {
  var Q, WatchPlugin;

  Q = require('q');

  WatchPlugin = (function() {
    function WatchPlugin(options, watcher) {
      this.options = options;
      this.watcher = watcher;
      this.watches = [];
    }

    WatchPlugin.prototype.watch = function(watch) {
      return this.watches.push(watch);
    };

    WatchPlugin.prototype.match = function(path) {
      return this.watches.some(function(w) {
        return w.match(path);
      });
    };

    WatchPlugin.prototype.watchesForPath = function(path) {
      return this.watches.select(function(w) {
        return w.match(path);
      });
    };

    WatchPlugin.prototype.outputPathsFor = function(path) {
      var w;

      return Q.all((function() {
        var _i, _len, _ref, _results;

        _ref = this.watchesForPath(path);
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          w = _ref[_i];
          _results.push(w.outputPathsFor(path));
        }
        return _results;
      }).call(this));
    };

    WatchPlugin.prototype.toString = function() {
      return this.constructor.name;
    };

    WatchPlugin.prototype.init = function(watcher) {
      return null;
    };

    WatchPlugin.prototype.dispose = function() {
      return null;
    };

    WatchPlugin.prototype.pathChanged = function(path) {
      var _this = this;

      return function() {
        return null;
      };
    };

    WatchPlugin.prototype.runAll = function() {
      return null;
    };

    WatchPlugin.prototype.kill = function() {};

    WatchPlugin.prototype.isPending = function() {
      return false;
    };

    return WatchPlugin;

  })();

  module.exports = WatchPlugin;

}).call(this);
