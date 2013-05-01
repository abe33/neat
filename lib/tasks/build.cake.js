(function() {
  var Builder, Neat, neatTask;

  Neat = require('../neat');

  Builder = Neat.require('tasks/build/builder');

  neatTask = Neat.require('utils/commands').neatTask;

  exports['build'] = neatTask({
    name: 'build',
    description: 'Run builds defined in the Neatfile',
    environment: 'default',
    action: function(callback) {
      return new Builder().init().then(function() {
        return typeof callback === "function" ? callback(0) : void 0;
      }).fail(function() {
        return typeof callback === "function" ? callback(1) : void 0;
      });
    }
  });

}).call(this);
