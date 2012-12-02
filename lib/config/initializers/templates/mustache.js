(function() {
  var error, puts, resolve, _ref;

  resolve = require('path').resolve;

  _ref = require('../../../utils/logs'), puts = _ref.puts, error = _ref.error;

  module.exports = function(config) {
    return config.engines.templates.mustache = {
      render: function(tpl, context) {
        var msg, to_html;
        try {
          to_html = require('mustache').to_html;
        } catch (e) {
          msg = "" + 'Mustache module not found, run neat install.'.red + "\n\n" + e.stack;
          return error(msg);
        }
        return to_html(tpl, context);
      }
    };
  };

}).call(this);
