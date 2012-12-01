(function() {
  var print;

  print = require('util').print;

  module.exports = function(config) {
    return config.engines.logging.console = function(logger, log) {
      if (log.level >= config.verbosity) {
        return print(log.message);
      }
    };
  };

}).call(this);
