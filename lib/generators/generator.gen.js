(function() {
  var Neat, describe, fs, generator, namedEntity, usages, _, _ref;

  fs = require('fs');

  Neat = require('../neat');

  _ref = Neat.require('utils/commands'), describe = _ref.describe, usages = _ref.usages;

  namedEntity = Neat.require('utils/generators').namedEntity;

  _ = Neat.i18n.getHelper();

  usages('neat generate generator <name>', describe(_('neat.commands.generate.generator.description'), generator = namedEntity(__filename, 'src/generators', 'gen.coffee')));

  module.exports = {
    generator: generator
  };

}).call(this);
