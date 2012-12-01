(function() {
  var Neat, error, green, info, neatTask, puts, red, run, warn, _, _ref, _ref1;

  Neat = require('../neat');

  _ref = Neat.require('utils/commands'), run = _ref.run, neatTask = _ref.neatTask;

  _ref1 = Neat.require('utils/logs'), error = _ref1.error, info = _ref1.info, green = _ref1.green, red = _ref1.red, puts = _ref1.puts, warn = _ref1.warn;

  _ = Neat.i18n.getHelper();

  exports.deploy = neatTask({
    name: 'deploy',
    description: _('neat.tasks.deploy.description'),
    action: function(callback) {
      return Neat.task('compile')(function(status) {
        if (status === 0) {
          return run('npm', ['install', '-g'], function(status) {
            if (status === 0) {
              info(green(_('neat.tasks.deploy.deploy_done')));
            } else {
              error(red(_('neat.tasks.deploy.deploy_failed')));
            }
            return typeof callback === "function" ? callback(status) : void 0;
          });
        } else {
          warn(_('neat.tasks.deploy.compile_failed'));
          return typeof callback === "function" ? callback(status) : void 0;
        }
      });
    }
  });

}).call(this);
