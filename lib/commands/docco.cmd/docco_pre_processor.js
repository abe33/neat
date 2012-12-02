(function() {
  var DoccoPreProcessor, Neat, error, fs, highlight, parse, resolve, _;

  fs = require('fs');

  Neat = require('../../neat');

  resolve = require('path').resolve;

  error = Neat.require('utils/logs').error;

  _ = Neat.i18n.getHelper();

  try {
    parse = require('docco').parse;
  } catch (e) {
    return error(_('neat.commands.docco.missing_module', {
      missing: missing('docco')
    }));
  }

  try {
    highlight = require('highlight.js').highlight;
  } catch (e) {
    return error(_('neat.commands.docco.missing_module', {
      missing: missing('docco')
    }));
  }

  DoccoPreProcessor = (function() {
    var END_TAG, START_TAG;

    START_TAG = '<pre><code>';

    END_TAG = '</code></pre>';

    DoccoPreProcessor.asCommand = function(p, c) {
      return function(cb) {
        return new DoccoPreProcessor(p, c).process(cb);
      };
    };

    function DoccoPreProcessor(path, section) {
      this.path = path;
      this.section = section;
    }

    DoccoPreProcessor.prototype.process = function(callback) {
      this.cursor = 0;
      if (!this.hasTags()) {
        return typeof callback === "function" ? callback() : void 0;
      }
      return this.processTag(callback);
    };

    DoccoPreProcessor.prototype.hasTags = function() {
      return this.section.docs_html.indexOf(START_TAG, this.cursor) !== -1;
    };

    DoccoPreProcessor.prototype.processTag = function(callback) {
      var code, endTagPos, match, pre, res, startTagPos;
      startTagPos = this.section.docs_html.indexOf(START_TAG, this.cursor);
      endTagPos = this.section.docs_html.indexOf(END_TAG, this.cursor);
      code = this.section.docs_html.substring(startTagPos + START_TAG.length, endTagPos);
      pre = {
        docs_text: '',
        code_text: code.strip().replace(/&gt;/g, '>').replace(/&lt;/g, '<')
      };
      res = highlight('coffeescript', pre.code_text);
      pre.code_html = res.value;
      pre.code_html = "" + START_TAG + pre.code_html + END_TAG;
      match = "" + START_TAG + code + END_TAG;
      match = "" + START_TAG + code + END_TAG;
      this.section.docs_html = this.section.docs_html.replace(match, pre.code_html);
      this.cursor = startTagPos + pre.code_html.length;
      if (this.hasTags()) {
        return this.processTag(callback);
      } else {
        return typeof callback === "function" ? callback() : void 0;
      }
    };

    return DoccoPreProcessor;

  })();

  module.exports = DoccoPreProcessor;

}).call(this);
