(function() {
  var Neat, Q, Watcher, fs, neatTask, path;

  fs = require('fs');

  path = require('path');

  Q = require('q');

  Neat = require('../neat');

  Watcher = require('./watch/watcher');

  neatTask = Neat.require('utils/commands').neatTask;

  exports['watch'] = neatTask({
    name: 'watch',
    description: 'Run watchers defined in the Watchfile',
    environment: 'default',
    action: function(callback) {
      return new Watcher().init();
    }
  });

}).call(this);
