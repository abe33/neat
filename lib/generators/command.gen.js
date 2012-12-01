(function() {
  var Neat, command, describe, fs, namedEntity, usages, _, _ref;

  fs = require('fs');

  Neat = require('../neat');

  _ref = Neat.require('utils/commands'), describe = _ref.describe, usages = _ref.usages;

  namedEntity = Neat.require('utils/generators').namedEntity;

  _ = Neat.i18n.getHelper();

  usages('neat generate command <name> {description, environment, usages}', describe(_('neat.commands.generate.command.description'), command = namedEntity(__filename, 'src/commands', 'cmd.coffee')));

  module.exports = {
    command: command
  };

}).call(this);
