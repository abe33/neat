(function() {
  var error, puts, resolve, _ref;

  resolve = require('path').resolve;

  _ref = require('../../../utils/logs'), puts = _ref.puts, error = _ref.error;

  module.exports = function(config) {
    return config.engines.templates.stylus = {
      render: function(tpl, context) {
        var compile, e, msg, output;

        try {
          compile = require('stylus');
        } catch (_error) {
          e = _error;
          msg = "" + 'Stylus module not found, run neat install.'.red + "\n\n" + e.stack;
          return error(msg);
        }
        output = null;
        compile(tpl).render(function(err, css) {
          if (err != null) {
            throw err;
          }
          return output = css;
        });
        return output;
      }
    };
  };

}).call(this);
