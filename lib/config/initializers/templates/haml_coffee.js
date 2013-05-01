(function() {
  var error, puts, resolve, _ref;

  resolve = require('path').resolve;

  _ref = require('../../../utils/logs'), puts = _ref.puts, error = _ref.error;

  module.exports = function(config) {
    return config.engines.templates.hamlc = {
      render: function(tpl, context) {
        var compile, e, msg;

        try {
          compile = require('haml-coffee').compile;
        } catch (_error) {
          e = _error;
          msg = "" + 'Haml-coffee module not found, run neat install.'.red + "\n\n" + e.stack;
          return error(msg);
        }
        return compile(tpl)(context);
      }
    };
  };

}).call(this);
