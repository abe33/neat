(function() {
  var Neat, context, describe, fs, functional, meta, namedEntity, namespace, relative, resolve, unit, usages, _, _ref, _ref1;

  fs = require('fs');

  _ref = require('path'), relative = _ref.relative, resolve = _ref.resolve;

  Neat = require('../neat');

  _ref1 = Neat.require('utils/commands'), describe = _ref1.describe, usages = _ref1.usages;

  namespace = Neat.require('utils/exports').namespace;

  namedEntity = Neat.require('utils/generators').namedEntity;

  _ = Neat.i18n.getHelper();

  meta = function(name, target) {
    return usages("neat generate spec:" + name + " <name>", describe(_("neat.commands.generate.spec." + name + ".description"), target));
  };

  context = {
    relative: relative,
    root: Neat.root,
    testPath: resolve(Neat.root, 'test')
  };

  meta('unit', unit = namedEntity(__filename, 'test/units', 'spec.coffee', context));

  meta('functional', functional = namedEntity(__filename, 'test/functionals', 'spec.coffee', context));

  module.exports = namespace('spec', {
    unit: unit,
    functional: functional
  });

}).call(this);
