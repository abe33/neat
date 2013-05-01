(function() {
  var Neat, deprecated, describe, ensurePath, fs, namedEntity, notOutsideNeat, packagerConfig, render, resolve, touch, usages, _, _ref, _ref1,
    __slice = [].slice;

  fs = require('fs');

  resolve = require('path').resolve;

  Neat = require('../neat');

  _ref = Neat.require('utils/commands'), describe = _ref.describe, usages = _ref.usages, deprecated = _ref.deprecated;

  namedEntity = Neat.require('utils/generators').namedEntity;

  render = Neat.require("utils/templates").render;

  _ref1 = Neat.require("utils/files"), touch = _ref1.touch, ensurePath = _ref1.ensurePath;

  notOutsideNeat = Neat.require("utils/logs").notOutsideNeat;

  _ = Neat.i18n.getHelper();

  deprecated('The old packager based compilation will no longer\
be supported in future version of Neat. Use a Neatfile and The\
cake build task instead.'.squeeze(), usages('neat generate config:packager <name>', describe(_('neat.commands.generate.config_packager.description'), packagerConfig = namedEntity(__filename, 'config/packages', 'cup'))));

  exports['config:packager'] = packagerConfig;

  deprecated('The old packager based compilation will no longer\
be supported in future version of Neat. Use a Neatfile and The\
cake build task instead.'.squeeze(), usages('neat generate config:packager:compile', describe('Generates the default compilation config for older projects', exports['config:packager:compile'] = function() {
    var args, cb, generator, path, _i;

    generator = arguments[0], args = 3 <= arguments.length ? __slice.call(arguments, 1, _i = arguments.length - 1) : (_i = 1, []), cb = arguments[_i++];
    if (Neat.root == null) {
      throw new Error(notOutsideNeat('config:packager:compile'));
    }
    path = resolve(__dirname, 'config_packager/compile');
    return render(path, function(err, result) {
      if (err != null) {
        return typeof cb === "function" ? cb(err) : void 0;
      }
      return ensurePath("" + Neat.root + "/config/packages/compile.cup", function(err) {
        if (err != null) {
          return typeof cb === "function" ? cb(err) : void 0;
        }
        return touch("" + Neat.root + "/config/packages/compile.cup", result, function(err) {
          if (err != null) {
            return typeof cb === "function" ? cb(err) : void 0;
          }
          return typeof cb === "function" ? cb() : void 0;
        });
      });
    });
  })));

}).call(this);
