(function() {
  var COFFEE, Neat, aliases, describe, environment, error, fs, generate, green, info, install, notOutsideNeat, puts, red, render, resolve, run, _, _ref, _ref1,
    __slice = [].slice;

  fs = require('fs');

  resolve = require('path').resolve;

  Neat = require('../neat');

  COFFEE = "" + Neat.neatRoot + "/node_modules/.bin/coffee";

  _ref = Neat.require("utils/logs"), puts = _ref.puts, error = _ref.error, info = _ref.info, green = _ref.green, red = _ref.red, notOutsideNeat = _ref.notOutsideNeat;

  _ref1 = Neat.require("utils/commands"), run = _ref1.run, aliases = _ref1.aliases, describe = _ref1.describe, environment = _ref1.environment;

  generate = Neat.require('generators')['package.json'];

  render = Neat.require("utils/templates").render;

  _ = Neat.i18n.getHelper();

  install = function(pr) {
    var f;

    if (pr == null) {
      throw new Error(_('neat.commands.no_program', {
        command: 'install'
      }));
    }
    return aliases('i', 'install', environment('all', describe(_('neat.commands.install.description'), f = function() {
      var args, callback, _i;

      args = 2 <= arguments.length ? __slice.call(arguments, 0, _i = arguments.length - 1) : (_i = 0, []), callback = arguments[_i++];
      if (Neat.root == null) {
        throw new Error(notOutsideNeat('neat install'));
      }
      return fs.readFile('Nemfile', function(err, nemfile) {
        if (err) {
          throw new Error(_('neat.errors.no_nemfile'));
        }
        puts("Nemfile found");
        return render(__filename, function(err, source) {
          if (err != null) {
            throw err;
          }
          source = source.replace("###_NPM_DECLARATION_###", nemfile.toString());
          source = source.replace("###_ENV_###", "env = '" + Neat.env + "'");
          return run(COFFEE, ['-e', source], function(status) {
            if (status === 0) {
              info(green(_('neat.commands.install.install_done')));
            } else {
              error(red(_('neat.commands.install.install_failed')));
            }
            return generate('package.json', function() {
              return typeof callback === "function" ? callback() : void 0;
            });
          });
        });
      });
    })));
  };

  module.exports = {
    install: install
  };

}).call(this);
