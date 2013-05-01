(function() {
  var Neat, basename, describe, ensureSync, error, extname, green, hashArguments, missing, namespace, project, puts, render, resolve, touchSync, usages, warn, _, _ref, _ref1, _ref2, _ref3,
    __slice = [].slice;

  _ref = require('path'), resolve = _ref.resolve, basename = _ref.basename, extname = _ref.extname;

  Neat = require('../neat');

  _ref1 = Neat.require("utils/logs"), puts = _ref1.puts, error = _ref1.error, warn = _ref1.warn, missing = _ref1.missing, green = _ref1.green;

  _ref2 = Neat.require("utils/files"), ensureSync = _ref2.ensureSync, touchSync = _ref2.touchSync;

  namespace = Neat.require("utils/exports").namespace;

  render = Neat.require("utils/templates").renderSync;

  _ref3 = Neat.require("utils/commands"), usages = _ref3.usages, describe = _ref3.describe, hashArguments = _ref3.hashArguments;

  _ = Neat.i18n.getHelper();

  usages('neat generate project <name> {description, author, keywords}', describe(_('neat.commands.generate.project.description'), project = function() {
    var a, args, b, base, c, callback, context, d, dirs, e, ext, files, generator, name, path, t, tplpath, _i, _j, _k, _len, _len1, _ref4;

    generator = arguments[0], name = arguments[1], args = 4 <= arguments.length ? __slice.call(arguments, 2, _i = arguments.length - 1) : (_i = 2, []), callback = arguments[_i++];
    if (name == null) {
      throw new Error(_('neat.errors.missing_argument', {
        name: name
      }));
    }
    if (args.length === 0 && typeof callback !== 'function') {
      args.push(callback);
    }
    path = resolve('.', name);
    base = basename(__filename);
    ext = extname(__filename);
    tplpath = resolve(__dirname, 'project');
    context = args.empty() ? {} : hashArguments(args);
    context.merge({
      name: name,
      version: Neat.meta.version
    });
    ensureSync(path);
    dirs = ['lib', 'src', 'src/commands', 'src/config', 'src/config/environments', 'src/config/initializers', 'src/generators', 'src/tasks', 'templates', 'test', 'test/fixtures', 'test/helpers', 'test/functionals', 'test/integrations', 'test/units'];
    files = [['lib/.gitkeep'], ['src/commands/.gitkeep'], ['src/config/environments/default.coffee', true], ['src/config/environments/development.coffee', true], ['src/config/environments/production.coffee', true], ['src/config/environments/test.coffee', true], ['src/config/initializers/.gitkeep'], ['src/generators/.gitkeep'], ['src/tasks/.gitkeep'], ['templates/.gitkeep'], ['test/fixtures/.gitkeep'], ['test/helpers/.gitkeep'], ['test/functionals/.gitkeep'], ['test/integrations/.gitkeep'], ['test/test_helper.coffee', true], ['test/units/.gitkeep'], ['.gitignore', true], ['.neat', true], ['.npmignore', true], ['Cakefile', true], ['Nemfile', true], ['Neatfile', true], ['Watchfile', true]];
    t = function(a, b, c) {
      var p, _ref4;

      if (c == null) {
        c = false;
      }
      if (typeof b === 'boolean') {
        _ref4 = [a, b], b = _ref4[0], c = _ref4[1];
      }
      if (b == null) {
        b = a;
      }
      p = resolve(path, a);
      if (c) {
        touchSync(p, render(resolve(tplpath, b), context));
      } else {
        touchSync(p);
      }
      return puts(green(_('neat.commands.generate.project.generation_done', {
        path: p
      })), 1);
    };
    e = function(d) {
      var p;

      p = resolve(path, d);
      ensureSync(p);
      return puts(green(_('neat.commands.generate.project.generation_done', {
        path: p
      })), 1);
    };
    try {
      for (_j = 0, _len = dirs.length; _j < _len; _j++) {
        d = dirs[_j];
        e(d);
      }
      for (_k = 0, _len1 = files.length; _k < _len1; _k++) {
        _ref4 = files[_k], a = _ref4[0], b = _ref4[1], c = _ref4[2];
        t(a, b, c);
      }
    } catch (_error) {
      e = _error;
      e.message = _('neat.commands.generate.project.generation_failed', {
        message: e.message
      });
      throw e;
    }
    return typeof callback === "function" ? callback() : void 0;
  }));

  module.exports = {
    project: project
  };

}).call(this);
