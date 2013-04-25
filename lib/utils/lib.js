(function() {
  var deprecated, inverse, puts, yellow, _ref;

  _ref = require('./logs'), puts = _ref.puts, yellow = _ref.yellow, inverse = _ref.inverse;

  deprecated = function(message) {
    return puts(yellow("" + (inverse(' DEPRECATED ')) + " " + message), 5);
  };

  module.exports = {
    deprecated: deprecated
  };

}).call(this);
