(function() {
  var Neat, describe, ensurePathSync, error, fs, green, hashArguments, info, missing, namedEntity, notOutsideNeat, render, resolve, usages, utils, _, _ref, _ref1,
    __slice = [].slice;

  fs = require('fs');

  resolve = require('path').resolve;

  Neat = require('../neat');

  utils = resolve(Neat.neatRoot, "lib/utils");

  ensurePathSync = require(resolve(utils, "files")).ensurePathSync;

  _ref = require(resolve(utils, "commands")), describe = _ref.describe, usages = _ref.usages, hashArguments = _ref.hashArguments;

  render = require(resolve(utils, "templates")).render;

  _ref1 = require(resolve(utils, "logs")), error = _ref1.error, info = _ref1.info, green = _ref1.green, missing = _ref1.missing, notOutsideNeat = _ref1.notOutsideNeat;

  _ = Neat.i18n.getHelper();

  namedEntity = function(src, dir, ext, ctx, requireNeat) {
    if (ctx == null) {
      ctx = {};
    }
    if (requireNeat == null) {
      requireNeat = true;
    }
    return function() {
      var a, args, cb, context, generator, name, path, _i;
      generator = arguments[0], name = arguments[1], args = 4 <= arguments.length ? __slice.call(arguments, 2, _i = arguments.length - 1) : (_i = 2, []), cb = arguments[_i++];
      if (requireNeat) {
        if (Neat.root == null) {
          throw new Error(notOutsideNeat(process.argv.join(" ")));
        }
      }
      if (typeof name !== 'string') {
        throw new Error(_('neat.errors.missing_argument', {
          name: 'name'
        }));
      }
      a = name.split('/');
      name = a.pop();
      dir = resolve(Neat.root, "" + dir + "/" + (a.join('/')));
      path = resolve(dir, "" + name + "." + ext);
      context = args.empty() ? {} : hashArguments(args);
      context.merge(ctx);
      context.merge({
        name: name,
        path: path,
        dir: dir
      });
      return fs.exists(path, function(exists) {
        if (exists) {
          throw new Error(_('neat.commands.generate.file_exists', {
            file: path
          }));
        }
        return render(src, context, function(err, data) {
          if (err != null) {
            throw new Error("" + (missing(_('neat.templates.template_for', {
              file: src
            }))) + "\n\n" + err.stack);
          }
          ensurePathSync(dir);
          return fs.writeFile(path, data, function(err) {
            if (err) {
              throw new Error(_('neat.errors.file_write', {
                file: path,
                stack: e.stack
              }));
            }
            path = "" + dir + "/" + name + "." + ext;
            info(green(_('neat.commands.generate.file_generated', {
              path: path
            })));
            return typeof cb === "function" ? cb() : void 0;
          });
        });
      });
    };
  };

  module.exports = {
    namedEntity: namedEntity
  };

}).call(this);
