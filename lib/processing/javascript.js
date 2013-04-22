(function() {
  var Neat, Q, check, checkBuffer, parser, pro, uglify, _ref, _ref1;

  Q = require('q');

  Neat = require('../neat');

  _ref = require('uglify-js'), parser = _ref.parser, pro = _ref.uglify;

  _ref1 = require('./utils'), check = _ref1.check, checkBuffer = _ref1.checkBuffer;

  uglify = function(buffer) {
    checkBuffer(buffer);
    return Q.fcall(function() {
      var ast, content, newBuffer, path;
      newBuffer = {};
      for (path in buffer) {
        content = buffer[path];
        ast = parser.parse(content);
        ast = pro.ast_mangle(ast);
        ast = pro.ast_squeeze(ast);
        newBuffer[path.replace(/\.js$/g, '.min.js')] = pro.gen_code(ast);
      }
      return newBuffer;
    });
  };

  module.exports = {
    uglify: uglify
  };

}).call(this);
