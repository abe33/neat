(function() {
  var Neat, describe, ensurePathSync, error, fs, green, hashArguments, info, missing, multiEntity, namedEntity, noExtension, notOutsideNeat, render, resolve, usages, _, _ref, _ref1, _ref2,
    __slice = [].slice;

  fs = require('fs');

  resolve = require('path').resolve;

  Neat = require('../neat');

  _ref = Neat.require('utils/files'), ensurePathSync = _ref.ensurePathSync, noExtension = _ref.noExtension;

  _ref1 = Neat.require('utils/commands'), describe = _ref1.describe, usages = _ref1.usages, hashArguments = _ref1.hashArguments;

  render = Neat.require('utils/templates').render;

  _ref2 = Neat.require('utils/logs'), error = _ref2.error, info = _ref2.info, green = _ref2.green, missing = _ref2.missing, notOutsideNeat = _ref2.notOutsideNeat;

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
          throw new Error(notOutsideNeat(process.argv.join(' ')));
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

  multiEntity = function(src, entities, ctx, requireNeat) {
    if (ctx == null) {
      ctx = {};
    }
    if (requireNeat == null) {
      requireNeat = true;
    }
    return function() {
      var a, args, cb, generator, name, options, partials, _i;
      generator = arguments[0], name = arguments[1], args = 4 <= arguments.length ? __slice.call(arguments, 2, _i = arguments.length - 1) : (_i = 2, []), cb = arguments[_i++];
      if (requireNeat) {
        if (Neat.root == null) {
          throw new Error(notOutsideNeat(process.argv.join(' ')));
        }
      }
      if (typeof name !== 'string') {
        throw new Error(_('neat.errors.missing_argument', {
          name: 'name'
        }));
      }
      a = name.split('/');
      name = a.pop();
      options = args.empty() ? {} : hashArguments(args);
      partials = {
        unit: resolve(src, '../spec.gen.coffee'),
        functional: resolve(src, '../spec.gen.coffee'),
        helper: resolve(noExtension(src), 'helper')
      };
      return entities.each(function(k, v) {
        var context, dir, ext, partial, path;
        if ((options[k] != null) && !options[k]) {
          return;
        }
        dir = v.dir, ext = v.ext;
        dir = resolve(Neat.root, "" + dir + "/" + (a.join('/')));
        path = resolve(dir, "" + name + ext);
        partial = partials[k] || src;
        context = ctx.concat();
        context.merge(options);
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
          return render(partial, context, function(err, data) {
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
              path = "" + dir + "/" + name + ext;
              info(green(_('neat.commands.generate.file_generated', {
                path: path
              })));
              return typeof cb === "function" ? cb() : void 0;
            });
          });
        });
      });
    };
  };

  module.exports = {
    namedEntity: namedEntity,
    multiEntity: multiEntity
  };

}).call(this);
