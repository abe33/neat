(function() {
  var findSync;

  findSync = require("../../../utils/files").findSync;

  module.exports = function(config) {
    var d, dirs, sources, _i, _len, _ref;

    dirs = ['src'];
    sources = [];
    for (_i = 0, _len = dirs.length; _i < _len; _i++) {
      d = dirs[_i];
      sources = sources.concat((_ref = findSync('coffee', d)) != null ? _ref.sort() : void 0);
    }
    return config.docco = {
      paths: {
        sources: sources.compact()
      }
    };
  };

}).call(this);
