(function() {
  var Neat, describe, fs, initializer, namedEntity, usages, _, _ref;

  fs = require('fs');

  Neat = require('../neat');

  _ref = Neat.require('utils/commands'), describe = _ref.describe, usages = _ref.usages;

  namedEntity = Neat.require('utils/generators').namedEntity;

  _ = Neat.i18n.getHelper();

  usages('neat generate initializer <name>', describe(_('neat.commands.generate.initializer.description'), initializer = namedEntity(__filename, 'src/config/initializers', 'coffee')));

  module.exports = {
    initializer: initializer
  };

}).call(this);
