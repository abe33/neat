(function() {
  var Neat, combine, paths;

  Neat = require('../neat');

  combine = Neat.require("utils/exports").combine;

  paths = Neat.paths.map(function(p) {
    return "" + p + "/lib/processing";
  });

  module.exports = combine(/\.build$/, paths);

}).call(this);
