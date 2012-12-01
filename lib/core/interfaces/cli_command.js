(function() {
  var CLICommand, isType;

  isType = require('../../utils/matchers').isType;

  CLICommand = {
    __definition__: function(o) {
      return typeof o === 'function' && (o.aliases != null) && Array.isArray(o.aliases) && o.aliases.every(isType('string'));
    }
  };

  module.exports = CLICommand;

}).call(this);
