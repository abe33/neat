(function() {
  var DoccoFileProcessor, DoccoTitleProcessor, Neat, e, error, fs, highlight, marked, missing, parallel, parse, puts, render, resolve, _, _ref;

  fs = require('fs');

  resolve = require('path').resolve;

  Neat = require('../../neat');

  DoccoTitleProcessor = require('./docco_title_processor');

  _ref = Neat.require('utils/logs'), puts = _ref.puts, error = _ref.error, missing = _ref.missing;

  render = Neat.require('utils/templates').render;

  parallel = Neat.require('async').parallel;

  _ = Neat.i18n.getHelper();

  try {
    parse = require('docco').parse;
  } catch (_error) {
    e = _error;
    return error(_('neat.errors.missing_module', {
      missing: missing('docco')
    }));
  }

  try {
    highlight = require('highlight.js').highlight;
  } catch (_error) {
    e = _error;
    return error(_('neat.errors.missing_module', {
      missing: missing('highlight')
    }));
  }

  try {
    marked = require('marked');
  } catch (_error) {
    e = _error;
    return error(_('neat.errors.missing_module', {
      missing: missing('marked')
    }));
  }

  marked.setOptions({
    gfm: true,
    pedantic: false,
    sanitize: false,
    highlight: function(code, lang) {
      return highlight(lang || 'coffeescript', code).value;
    }
  });

  DoccoFileProcessor = (function() {
    var TPL_PATH, TPL_TOC;

    TPL_PATH = resolve(__dirname.replace('.cmd', ''), '_page');

    TPL_TOC = resolve(__dirname.replace('.cmd', ''), '_toc');

    DoccoFileProcessor.asCommand = function(f, h, n) {
      return function(cb) {
        return new DoccoFileProcessor(f, h, n).process(cb);
      };
    };

    function DoccoFileProcessor(file, header, nav) {
      this.file = file;
      this.header = header;
      this.nav = nav;
    }

    DoccoFileProcessor.prototype.highlightFile = function(path, sections, callback) {
      var code_text, docs_text, o, presCmd, res, section, titles, titlesCmd, _i, _j, _len, _len1,
        _this = this;

      for (_i = 0, _len = sections.length; _i < _len; _i++) {
        o = sections[_i];
        code_text = o.code_text, docs_text = o.docs_text;
        res = highlight('coffeescript', code_text);
        o.code_html = "<pre>" + res.value + "</pre>";
        o.docs_html = marked(docs_text);
      }
      titles = [];
      presCmd = [];
      titlesCmd = [];
      for (_j = 0, _len1 = sections.length; _j < _len1; _j++) {
        section = sections[_j];
        titlesCmd.push(DoccoTitleProcessor.asCommand(path, section, titles));
      }
      return parallel(presCmd, function() {
        return parallel(titlesCmd, function() {
          return render(TPL_TOC, {
            titles: titles
          }, function(err, toc) {
            if (err != null) {
              throw err;
            }
            return callback(toc);
          });
        });
      });
    };

    DoccoFileProcessor.prototype.process = function(callback) {
      var _this = this;

      return fs.readFile(this.file.path, function(err, code) {
        var sections;

        if (err != null) {
          throw err;
        }
        sections = parse(_this.file.path, code.toString());
        return _this.highlightFile(_this.file.path, sections, function(toc) {
          var context;

          context = {
            sections: sections,
            header: _this.header,
            nav: _this.nav,
            file: _this.file
          };
          return render(TPL_PATH, context, function(err, page) {
            if (err != null) {
              throw err;
            }
            page = page.replace(/@toc/g, toc);
            return fs.writeFile(_this.file.outputPath, page, function(err) {
              if (err != null) {
                throw err;
              }
              puts(_('neat.commands.docco.file_generated', {
                file: _this.file.relativePath.yellow
              }), 1);
              return typeof callback === "function" ? callback() : void 0;
            });
          });
        });
      });
    };

    return DoccoFileProcessor;

  })();

  module.exports = DoccoFileProcessor;

}).call(this);
