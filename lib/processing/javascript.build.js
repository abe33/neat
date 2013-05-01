(function() {
  var Neat, Q, check, checkBuffer, uglifier, uglify, _ref;

  Q = require('q');

  Neat = require('../neat');

  uglifier = require('uglify-js');

  _ref = require('./utils'), check = _ref.check, checkBuffer = _ref.checkBuffer;

  uglify = function(buffer) {
    checkBuffer(buffer);
    return Q.fcall(function() {
      var content, newBuffer, output, path;

      newBuffer = {};
      for (path in buffer) {
        content = buffer[path];
        output = path.replace(/\.js$/g, '.min.js');
        newBuffer[output] = uglifier.minify(content, {
          fromString: true
        });
      }
      return newBuffer;
    }).fail(function(err) {
      console.log(err.message);
      return console.log(err.stack);
    });
  };

  module.exports = {
    uglify: uglify
  };

}).call(this);
