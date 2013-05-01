(function() {
  var DoccoTitleProcessor;

  DoccoTitleProcessor = (function() {
    DoccoTitleProcessor.asCommand = function(p, c, t) {
      return function(cb) {
        return new DoccoTitleProcessor(p, c, t).process(cb);
      };
    };

    function DoccoTitleProcessor(path, section, titles) {
      this.path = path;
      this.section = section;
      this.titles = titles;
      this.START_TAG = /<h(\d)>/g;
      this.END_TAG = /<\/h(\d)>/g;
    }

    DoccoTitleProcessor.prototype.process = function(callback) {
      return this.processTag(callback);
    };

    DoccoTitleProcessor.prototype.hasTags = function() {
      return this.section.docs_html.search(this.START_TAG, this.cursor) !== -1;
    };

    DoccoTitleProcessor.prototype.processTag = function(callback) {
      var content, endMatch, id, level, match, replacement, startMatch;

      startMatch = this.START_TAG.exec(this.section.docs_html);
      if (startMatch != null) {
        level = parseInt(startMatch[1]);
        endMatch = this.END_TAG.exec(this.section.docs_html);
        content = this.section.docs_html.substring(this.START_TAG.lastIndex, endMatch.index);
        id = content.parameterize();
        match = "<h" + level + ">" + content + "</h" + level + ">";
        replacement = "<h" + level + " id='" + id + "'>" + content + "</h" + level + ">";
        this.section.docs_html = this.section.docs_html.replace(match, replacement);
        this.titles.push({
          id: id,
          content: content,
          level: level
        });
        this.START_TAG.lastIndex += id.length + 6;
        this.END_TAG.lastIndex += id.length + 6;
        return this.processTag(callback);
      } else {
        return typeof callback === "function" ? callback() : void 0;
      }
    };

    return DoccoTitleProcessor;

  })();

  module.exports = DoccoTitleProcessor;

}).call(this);
