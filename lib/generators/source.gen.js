(function() {
  var Neat, context, describe, entities, fs, multiEntity, relative, render, resolve, source, touch, usages, _, _ref, _ref1;

  fs = require('fs');

  _ref = require('path'), resolve = _ref.resolve, relative = _ref.relative;

  Neat = require('../neat');

  _ref1 = Neat.require('utils/commands'), describe = _ref1.describe, usages = _ref1.usages;

  multiEntity = Neat.require('utils/generators').multiEntity;

  render = Neat.require("utils/templates").render;

  touch = Neat.require("utils/files").touch;

  _ = Neat.i18n.getHelper();

  entities = {
    source: {
      dir: 'src',
      ext: '.coffee'
    },
    unit: {
      dir: 'test/units',
      ext: '.spec.coffee',
      partial: '../spec.gen.coffee'
    },
    functional: {
      dir: 'test/functionals',
      ext: '.spec.coffee',
      partial: '../spec.gen.coffee'
    },
    helper: {
      dir: 'test/helpers',
      ext: '_helper.coffee',
      partial: 'helper'
    }
  };

  context = {
    relative: relative,
    root: Neat.root,
    testPath: resolve(Neat.root, 'test'),
    hasSource: true
  };

  usages('neat generate source <name> [options] {helper, functional, unit}', describe(_('neat.commands.generate.source.description'), source = multiEntity(__filename, entities, context)));

  exports['source'] = source;

}).call(this);
