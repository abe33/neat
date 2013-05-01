(function() {
  var DoccoFile, Neat, basename, extname, relative, _ref;

  _ref = require('path'), basename = _ref.basename, extname = _ref.extname, relative = _ref.relative;

  Neat = require('../../neat');

  DoccoFile = (function() {
    function DoccoFile(path) {
      var outputBase;

      this.path = path;
      this.relativePath = relative(Neat.root, this.path);
      this.basename = basename(this.path);
      outputBase = this.relativePath.replace(extname(this.path), '').underscore();
      this.outputPath = "" + Neat.root + "/docs/" + outputBase + ".html";
      this.linkPath = relative("" + Neat.root + "/docs", this.outputPath);
    }

    return DoccoFile;

  })();

  module.exports = DoccoFile;

}).call(this);
