(function() {
  var I18n, findSync, readFilesSync, yaml, _ref;

  yaml = require('js-yaml');

  _ref = require('../utils/files'), findSync = _ref.findSync, readFilesSync = _ref.readFilesSync;

  I18n = (function() {
    function I18n(paths, defaultLanguage) {
      this.paths = paths != null ? paths : [];
      this.defaultLanguage = defaultLanguage != null ? defaultLanguage : 'en';
    }

    I18n.prototype.get = function(language, path) {
      var els, lang, v, _i, _len, _ref1;

      if (path == null) {
        _ref1 = [this.defaultLanguage, language], language = _ref1[0], path = _ref1[1];
      }
      lang = this.locales[language];
      if (lang == null) {
        throw new Error("Language " + language + " not found");
      }
      els = path.split('.');
      for (_i = 0, _len = els.length; _i < _len; _i++) {
        v = els[_i];
        lang = lang[v];
        if (lang == null) {
          break;
        }
      }
      if (lang == null) {
        lang = els.last().replace(/[-_]/g, ' ').capitalizeAll();
      }
      return lang;
    };

    I18n.prototype.getHelper = function() {
      var _this = this;

      return function(path, tokens) {
        return _this.get(path).replace(/\#\{([^\}]+)\}/g, function(token, key) {
          if (tokens[key] == null) {
            return token;
          }
          return tokens[key];
        });
      };
    };

    I18n.prototype.load = function() {
      var content, docs, path;

      this.locales = {};
      docs = readFilesSync(findSync('yml', this.paths));
      for (path in docs) {
        content = docs[path];
        this.deepMerge(this.locales, yaml.load(content.toString()));
      }
      return this.languages = this.locales.sortedKeys();
    };

    I18n.prototype.deepMerge = function(target, source) {
      var k, v, _results;

      _results = [];
      for (k in source) {
        v = source[k];
        switch (typeof v) {
          case 'object':
            if (Array.isArray(v)) {
              target[k] || (target[k] = []);
              _results.push(target[k] = target[k].concat(v));
            } else {
              target[k] || (target[k] = {});
              _results.push(this.deepMerge(target[k], v));
            }
            break;
          default:
            _results.push(target[k] = v);
        }
      }
      return _results;
    };

    return I18n;

  })();

  module.exports = I18n;

}).call(this);
