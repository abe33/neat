(function() {
  var Q, coffee, compile;

  Q = require('q');

  coffee = require('coffee-script').compile;

  compile = function(options) {
    return function(buffer) {
      return Q.fcall(function() {
        var content, newBuffer, path;
        newBuffer = {};
        try {
          for (path in buffer) {
            content = buffer[path];
            newBuffer[path.replace('.coffee', '.js')] = coffee(content, options);
          }
        } catch (e) {
          throw new Error("In file '" + path + "': " + e.message);
        }
        return newBuffer;
      });
    };
  };

  module.exports = {
    compile: compile
  };

}).call(this);
