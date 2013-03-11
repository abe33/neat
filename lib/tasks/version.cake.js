(function() {
  var Neat, error, green, info, neatTask, puts, red, run, _, _ref, _ref1;

  Neat = require('../neat');

  _ref = Neat.require('utils/commands'), run = _ref.run, neatTask = _ref.neatTask;

  _ref1 = Neat.require('utils/logs'), error = _ref1.error, info = _ref1.info, green = _ref1.green, red = _ref1.red, puts = _ref1.puts;

  _ = Neat.i18n.getHelper();

  exports['version'] = neatTask({
    name: 'version',
    description: _('neat.tasks.version.description'),
    environment: 'production',
    action: function(callback) {
      info(_('neat.tasks.version.message', {
        name: Neat.project.name,
        version: green(Neat.project.version)
      }));
      return typeof callback === "function" ? callback(0) : void 0;
    }
  });

}).call(this);
