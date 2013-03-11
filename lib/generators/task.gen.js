(function() {
  var Neat, describe, fs, namedEntity, task, usages, _, _ref;

  fs = require('fs');

  Neat = require('../neat');

  _ref = Neat.require('utils/commands'), describe = _ref.describe, usages = _ref.usages;

  namedEntity = Neat.require('utils/generators').namedEntity;

  _ = Neat.i18n.getHelper();

  usages('neat generate tasks <name> {description, environment}', describe(_('neat.commands.generate.task.description'), task = namedEntity(__filename, 'src/tasks', 'cake.coffee')));

  module.exports = {
    task: task
  };

}).call(this);
