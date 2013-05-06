(function() {
  var util;

  util = require('util');

  module.exports = function(config) {
    return config.engines.logging.console = function(logger, log) {
      if (log.level >= config.verbosity) {
        return util.print(log.message);
      }
    };
  };

}).call(this);
