(function() {
  var op;

  op = require('../../../tasks/package/operators');

  module.exports = function(config) {
    return config.tasks["package"] = {
      dir: "" + config.root + "/packages",
      conf: "" + config.root + "/config/packages",
      tmp: "" + config.root + "/.tmp",
      operatorsMap: {
        'annotate:class': op.annotateClass,
        'annotate:file': op.annotateFile,
        'compile': op.compile,
        'create:directory': op.createDirectory,
        'create:file': op.createFile,
        'exports:package': op.exportsToPackage,
        'join': op.join,
        'path:change': op.pathChange,
        'path:reset': op.pathReset,
        'strip:requires': op.stripRequires,
        'uglify': op.uglify
      }
    };
  };

}).call(this);
