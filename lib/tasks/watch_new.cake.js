(function() {
  var Neat, Q, Watcher, fs, neatTask, path;

  fs = require('fs');

  path = require('path');

  Q = require('q');

  Neat = require('../neat');

  Watcher = require('./watch/watcher');

  neatTask = Neat.require('utils/commands').neatTask;

  exports['watch:new'] = neatTask({
    name: 'watch:new',
    description: 'Attempt to create a smarter watch task',
    environment: 'default',
    action: function(callback) {
      return new Watcher().init();
    }
  });

}).call(this);
