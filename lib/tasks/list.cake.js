(function() {
  var Neat, error, first, green, info, last, length, neatTask, property, puts, red, run, _, _ref, _ref1, _ref2;

  Neat = require('../neat');

  _ref = Neat.require('utils/commands'), run = _ref.run, neatTask = _ref.neatTask;

  _ref1 = Neat.require('utils/logs'), error = _ref1.error, info = _ref1.info, green = _ref1.green, red = _ref1.red, puts = _ref1.puts;

  _ref2 = Neat.require('utils/mappers'), first = _ref2.first, last = _ref2.last, length = _ref2.length, property = _ref2.property;

  _ = Neat.i18n.getHelper();

  exports['list'] = neatTask({
    name: 'list',
    description: _('neat.tasts.list.description'),
    environment: 'production',
    action: function(callback) {
      var c1, c2, env, environment, k, t, task, tasks, v;

      tasks = Neat.require('tasks');
      t = tasks.flatten().group(2);
      c1 = t.map(first(length())).max() + 4;
      c2 = t.map(last(property('environment', length()))).compact().max() + 4;
      task = _('neat.tasks.list.task').left(c1);
      environment = _('neat.tasks.list.environment').left(c2);
      puts(("" + task + environment).yellow, 5);
      for (k in tasks) {
        v = tasks[k];
        env = v.environment != null ? v.environment.left(c2) : 'default'.left(c2);
        puts("" + (k.left(c1)) + env, 5);
      }
      return typeof callback === "function" ? callback(0) : void 0;
    }
  });

}).call(this);
