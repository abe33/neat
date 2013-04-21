(function() {
  var Builder, Neat, neatTask;

  Neat = require('../neat');

  Builder = Neat.require('tasks/build/builder');

  neatTask = Neat.require('utils/commands').neatTask;

  exports['build'] = neatTask({
    name: 'build',
    description: 'Attempt to create a promise-based build task',
    environment: 'default',
    action: function(callback) {
      return new Builder().init().then(callback);
    }
  });

}).call(this);
