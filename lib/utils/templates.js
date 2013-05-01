(function() {
  var Neat, error, extname, findSiblingFile, findSiblingFileSync, fs, missing, puts, render, renderSync, _, _ref, _ref1;

  fs = require('fs');

  extname = require('path').extname;

  Neat = require('../neat');

  _ref = require("../utils/files"), findSiblingFile = _ref.findSiblingFile, findSiblingFileSync = _ref.findSiblingFileSync;

  _ref1 = require("../utils/logs"), puts = _ref1.puts, error = _ref1.error, missing = _ref1.missing;

  _ = Neat.i18n.getHelper();

  render = function(file, context, callback) {
    var dir, _ref2;

    if (typeof context === 'function') {
      _ref2 = [{}, context], context = _ref2[0], callback = _ref2[1];
    }
    dir = Neat.config.templatesDirectoryName;
    return findSiblingFile(file, Neat.paths, dir, function(e, tplfile, a) {
      var ext, msg;

      if (e != null) {
        return typeof callback === "function" ? callback(e) : void 0;
      }
      if (tplfile == null) {
        msg = _('neat.templates.no_template', {
          paths: a.join("\n"),
          missing: _('neat.templates.template_for', {
            file: file
          })
        });
        return typeof callback === "function" ? callback(new Error(msg)) : void 0;
      }
      puts("template found: " + tplfile.yellow);
      ext = extname(tplfile).slice(1);
      render = Neat.config.engines.templates[ext].render;
      if (render == null) {
        return typeof callback === "function" ? callback(new Error(missing(_('neat.templates.backend_for', {
          ext: ext
        })))) : void 0;
      }
      puts("engine found for " + ext.cyan);
      return fs.readFile(tplfile, function(err, tpl) {
        if (err != null) {
          msg = _('neat.errors.file_access', {
            file: tplfile.red,
            stack: err.stack
          });
          if (typeof callback === "function") {
            callback(new Error(msg));
          }
        }
        return typeof callback === "function" ? callback(null, render(tpl.toString(), context)) : void 0;
      });
    });
  };

  renderSync = function(file, context) {
    var e, ext, msg, paths, tpl, tplfile;

    paths = [];
    console.log('');
    tplfile = findSiblingFileSync(file, Neat.paths, "templates", "*", paths);
    if (tplfile == null) {
      msg = _('neat.templates.no_template', {
        paths: paths.join("\n"),
        missing: _('neat.templates.template_for', {
          file: tplfile
        })
      });
      throw new Error(msg);
    }
    puts("template found: " + tplfile.yellow);
    ext = extname(tplfile).slice(1);
    render = Neat.config.engines.templates[ext].render;
    if (render == null) {
      throw new Error(missing(_('neat.templates.backend_for', {
        ext: ext
      })));
    }
    puts("engine found for " + ext.cyan);
    try {
      tpl = fs.readFileSync(tplfile);
    } catch (_error) {
      e = _error;
      e.message = error(_('neat.errors.file_access', {
        path: tplfile.red,
        stack: e.message
      }));
      throw e;
    }
    return render(tpl.toString(), context);
  };

  module.exports = {
    render: render,
    renderSync: renderSync
  };

}).call(this);
