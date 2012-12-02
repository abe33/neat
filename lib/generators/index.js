(function() {
  var Neat, combine, paths;

  Neat = require('../neat');

  combine = require("../utils/exports").combine;

  paths = Neat.paths.map(function(p) {
    return "" + p + "/lib/generators";
  });

  module.exports = combine(/\.gen$/, paths);

}).call(this);
