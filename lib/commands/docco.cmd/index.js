(function() {
  var DoccoFile, Neat, Processor, aliases, cmdgen, desc, describe, documentation, ensureSync, environment, error, fs, green, hashify, index, info, javascript, missing, name, namespace, parallel, render, resolve, stylesheet, warn, _, _ref, _ref1;

  fs = require('fs');

  resolve = require('path').resolve;

  Neat = require('../../neat');

  DoccoFile = require('./docco_file');

  Processor = require('./docco_file_processor');

  _ref = Neat.require('utils/logs'), error = _ref.error, info = _ref.info, warn = _ref.warn, missing = _ref.missing, green = _ref.green;

  _ref1 = Neat.require('utils/commands'), aliases = _ref1.aliases, describe = _ref1.describe, environment = _ref1.environment;

  ensureSync = Neat.require('utils/files').ensureSync;

  render = Neat.require('utils/templates').render;

  namespace = Neat.require('utils/exports').namespace;

  parallel = Neat.require('async').parallel;

  _ = Neat.i18n.getHelper();

  hashify = function(files) {
    var deepestLevel, end, file, filesHash, level, o, p, path, _i, _len, _name;

    filesHash = {};
    deepestLevel = 0;
    for (_i = 0, _len = files.length; _i < _len; _i++) {
      file = files[_i];
      path = file.relativePath.split('/');
      end = path.pop();
      o = filesHash[_name = path.shift()] || (filesHash[_name] = {});
      level = 1;
      while (path.length) {
        p = path.shift();
        level += 1;
        o = o[p] || (o[p] = {});
      }
      o[end] = file;
      level += 1;
      deepestLevel = Math.max(deepestLevel, level);
    }
    return [filesHash, deepestLevel];
  };

  cmdgen = function(name, desc, fn) {
    return function(pr) {
      var f;

      if (pr == null) {
        throw new Error(_('neat.commands.no_program', {
          command: name
        }));
      }
      return aliases(name, describe(desc, environment('production', f = function(callback) {
        if (Neat.root == null) {
          throw new Error(_("neat.errors.outside_neat", {
            expression: "neat " + name
          }));
        }
        ensureSync(resolve(Neat.root, 'docs'));
        return fn(pr, callback);
      })));
    };
  };

  name = 'docco:javascript';

  desc = _('neat.commands.docco.javascript_description');

  javascript = cmdgen(name, desc, function(pr, callback) {
    var dirname, jsTplPath;

    dirname = __dirname.replace('.cmd', '');
    jsTplPath = resolve(dirname, '_javascript');
    return render(jsTplPath, {}, function(err, js) {
      if (err != null) {
        throw err;
      }
      return fs.writeFile("" + Neat.root + "/docs/docco.js", js, function(err) {
        if (err != null) {
          throw err;
        }
        info(green(_('neat.commands.docco.javascript_generated')));
        return typeof callback === "function" ? callback() : void 0;
      });
    });
  });

  name = 'docco:stylesheet';

  desc = _('neat.commands.docco.stylesheet_description');

  stylesheet = cmdgen(name, desc, function(pr, callback) {
    return render(__dirname, function(err, css) {
      if (err != null) {
        throw err;
      }
      return fs.writeFile("" + Neat.root + "/docs/docco.css", css, function(err) {
        if (err != null) {
          throw err;
        }
        info(green(_('neat.commands.docco.stylesheet_generated')));
        return typeof callback === "function" ? callback() : void 0;
      });
    });
  });

  name = 'docco:documentation';

  desc = _('neat.commands.docco.description');

  documentation = cmdgen(name, desc, function(pr, callback) {
    var context, deepestLevel, dirname, files, filesHash, headerTplPath, navTplPath, pageTplPath, path, paths, _ref2;

    paths = Neat.config.docco.paths.sources.concat();
    if ((paths == null) || paths.empty()) {
      return warn(_('neat.commands.docco.no_path'));
    }
    dirname = __dirname.replace('.cmd', '');
    navTplPath = resolve(dirname, '_navigation');
    headerTplPath = resolve(dirname, '_header');
    pageTplPath = resolve(dirname, '_page');
    files = (function() {
      var _i, _len, _results;

      _results = [];
      for (_i = 0, _len = paths.length; _i < _len; _i++) {
        path = paths[_i];
        _results.push(new DoccoFile(path));
      }
      return _results;
    })();
    _ref2 = hashify(files), filesHash = _ref2[0], deepestLevel = _ref2[1];
    context = {
      files: files,
      filesHash: filesHash,
      deepestLevel: deepestLevel
    };
    return render(navTplPath, context, function(err, nav) {
      if (err != null) {
        throw err;
      }
      return render(headerTplPath, context, function(err, header) {
        var file, processors, _i, _len;

        if (err != null) {
          throw err;
        }
        processors = [];
        for (_i = 0, _len = files.length; _i < _len; _i++) {
          file = files[_i];
          processors.push(Processor.asCommand(file, header, nav));
        }
        return parallel(processors, function() {
          info(green(_('neat.commands.docco.documentation_generated')));
          return typeof callback === "function" ? callback() : void 0;
        });
      });
    });
  });

  name = 'docco';

  desc = _('neat.commands.docco.description');

  index = cmdgen(name, desc, function(pr, cb) {
    return javascript(pr)(function() {
      return stylesheet(pr)(function() {
        return documentation(pr)(cb);
      });
    });
  });

  module.exports = namespace('docco', {
    index: index,
    javascript: javascript,
    stylesheet: stylesheet,
    documentation: documentation
  });

}).call(this);
