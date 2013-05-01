(function() {
  var Neat, error, green, info, neatTaskAlias, red, rm, run, _, _ref, _ref1;

  Neat = require('../neat');

  _ref = require('../utils/commands'), run = _ref.run, neatTaskAlias = _ref.neatTaskAlias;

  _ref1 = require('../utils/logs'), error = _ref1.error, info = _ref1.info, green = _ref1.green, red = _ref1.red;

  rm = require('../utils/files').rm;

  _ = Neat.i18n.getHelper();

  exports.compile = neatTaskAlias('build', 'compile', 'production');

}).call(this);
