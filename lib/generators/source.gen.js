(function() {
  var Neat, describe, entities, fs, multiEntity, render, resolve, source, touch, usages, _, _ref;

  fs = require('fs');

  resolve = require('path').resolve;

  Neat = require('../neat');

  _ref = Neat.require('utils/commands'), describe = _ref.describe, usages = _ref.usages;

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
      ext: '.spec.coffee'
    },
    functional: {
      dir: 'test/functionals',
      ext: '.spec.coffee'
    },
    helper: {
      dir: 'test/helpers',
      ext: '_helper.coffee'
    }
  };

  usages('neat generate source <name> [options]', describe(_('neat.commands.generate.source.description'), source = multiEntity(__filename, entities)));

  exports['source'] = source;

}).call(this);
