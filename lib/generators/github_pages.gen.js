(function() {
  var Neat, basename, describe, ensureSync, error, extname, green, hashArguments, notOutsideNeat, puts, red, render, resolve, touchSync, usages, _, _ref, _ref1, _ref2, _ref3,
    __slice = [].slice;

  _ref = require('path'), resolve = _ref.resolve, basename = _ref.basename, extname = _ref.extname;

  Neat = require('../neat');

  _ref1 = Neat.require('utils/commands'), describe = _ref1.describe, usages = _ref1.usages, hashArguments = _ref1.hashArguments;

  render = Neat.require('utils/templates').renderSync;

  _ref2 = Neat.require('utils/files'), ensureSync = _ref2.ensureSync, touchSync = _ref2.touchSync;

  _ref3 = Neat.require('utils/logs'), puts = _ref3.puts, error = _ref3.error, green = _ref3.green, red = _ref3.red, notOutsideNeat = _ref3.notOutsideNeat;

  _ = Neat.i18n.getHelper();

  usages('neat generate github:pages', describe(_('neat.commands.generate.github_pages.description'), exports['github:pages'] = function() {
    var a, args, b, base, c, callback, context, d, dirs, e, ext, files, generator, path, t, tplpath, _i, _j, _k, _len, _len1, _ref4;

    generator = arguments[0], args = 3 <= arguments.length ? __slice.call(arguments, 1, _i = arguments.length - 1) : (_i = 1, []), callback = arguments[_i++];
    if (Neat.root == null) {
      throw new Error(notOutsideNeat(process.argv.join(' ')));
    }
    path = resolve('.');
    base = basename(__filename);
    ext = extname(__filename);
    tplpath = resolve(__dirname, 'github_pages');
    context = args.empty() ? {} : hashArguments(args);
    context.merge({
      version: Neat.meta.version
    });
    dirs = ['config', 'pages'];
    files = [['config/pages.cup', true], ['pages/index.md', true], ['pages/pages.stylus', true]];
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
      return puts(green(_('neat.commands.generate.github_pages.generation_done', {
        path: p
      })), 1);
    };
    e = function(d) {
      var p;

      p = resolve(path, d);
      ensureSync(p);
      return puts(green(_('neat.commands.generate.github_pages.generation_done', {
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
      e.message = _('neat.commands.generate.github_pages.generation_failed', {
        message: e.message
      });
      throw e;
    }
    return typeof callback === "function" ? callback() : void 0;
  }));

}).call(this);
