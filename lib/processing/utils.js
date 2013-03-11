(function() {
  var check, checkBuffer;

  check = function(arg, msg) {
    if (arg == null) {
      throw new Error(msg);
    }
  };

  checkBuffer = function(buffer) {
    if (buffer == null) {
      throw new Error('Buffer must be set');
    }
    if (typeof buffer !== 'object') {
      throw new Error('Buffer must be an object');
    }
  };

  module.exports = {
    checkBuffer: checkBuffer,
    check: check
  };

}).call(this);
