// Generated by CoffeeScript 1.3.3
(function() {
  var describe, fs, generator, namedEntity, usages, _ref;

  fs = require('fs');

  _ref = require('../utils/commands'), describe = _ref.describe, usages = _ref.usages;

  namedEntity = require('../utils/generators').namedEntity;

  usages('neat generate config:packager <name>', describe('Generates a <name> packager config in the config/packages directory', generator = namedEntity(__filename, 'src/config/packages', 'cup')));

  exports['config:packager'] = generator;

}).call(this);