(function() {
  var Neat, describe, ensurePath, environment, error, exists, fs, hashArguments, info, path, puts, render, resolve, usages, _, _ref, _ref1,
    __slice = [].slice;

  fs = require('fs');

  path = require('path');

  resolve = require('path').resolve;

  Neat = require('../neat');

  _ref = Neat.require("utils/commands"), describe = _ref.describe, usages = _ref.usages, environment = _ref.environment, hashArguments = _ref.hashArguments;

  _ref1 = Neat.require("utils/logs"), puts = _ref1.puts, error = _ref1.error, info = _ref1.info;

  render = Neat.require("utils/templates").render;

  ensurePath = Neat.require("utils/files").ensurePath;

  _ = Neat.i18n.getHelper();

  exists = fs.exists || path.exists;

  usages('neat generate config:lint {options}', describe(_('neat.commands.generate.config_lint.description'), exports['config:lint'] = function() {
    var args, cb, context, dir, generator, _i;

    generator = arguments[0], args = 3 <= arguments.length ? __slice.call(arguments, 1, _i = arguments.length - 1) : (_i = 1, []), cb = arguments[_i++];
    if (Neat.root == null) {
      throw new Error(notOutsideNeat(process.argv.join(" ")));
    }
    context = args.empty() ? {} : hashArguments(args);
    dir = resolve(Neat.root, 'config/tasks');
    path = "" + dir + "/lint.json";
    return exists(path, function(exists) {
      if (exists) {
        throw new Error(_('neat.commands.generate.file_exists', {
          file: path
        }));
      }
      return render(__filename, context, function(err, data) {
        if (err != null) {
          throw err;
        }
        return ensurePath(dir, function(err) {
          return fs.writeFile(path, data, function(err) {
            if (err != null) {
              throw new Error(_('neat.errors.file_write', {
                file: path,
                stack: e.stack
              }));
            }
            info(_('neat.commands.generate.config_lint.config_generated', {
              config: path
            }).green);
            return typeof cb === "function" ? cb() : void 0;
          });
        });
      });
    });
  }));

}).call(this);
