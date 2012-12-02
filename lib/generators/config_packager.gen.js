(function() {
  var Neat, describe, fs, namedEntity, packagerConfig, render, resolve, touch, usages, _, _ref,
    __slice = [].slice;

  fs = require('fs');

  resolve = require('path').resolve;

  Neat = require('../neat');

  _ref = Neat.require('utils/commands'), describe = _ref.describe, usages = _ref.usages;

  namedEntity = Neat.require('utils/generators').namedEntity;

  render = Neat.require("utils/templates").render;

  touch = Neat.require("utils/files").touch;

  _ = Neat.i18n.getHelper();

  usages('neat generate config:packager <name>', describe(_('neat.commands.generate.config_packager.description'), packagerConfig = namedEntity(__filename, 'config/packages', 'cup')));

  exports['config:packager'] = packagerConfig;

  exports['config:packager:compile'] = function() {
    var args, cb, generator, path, _i;
    generator = arguments[0], args = 3 <= arguments.length ? __slice.call(arguments, 1, _i = arguments.length - 1) : (_i = 1, []), cb = arguments[_i++];
    if (Neat.root == null) {
      throw new Error(notOutsideNeat('config:packager:compile'));
    }
    path = resolve(__dirname, 'config_packager/compile');
    return render(path, function(err, result) {
      return touch("" + Neat.root + "/config/packages/compile.cup", result, function(err) {
        return typeof cb === "function" ? cb() : void 0;
      });
    });
  };

}).call(this);
