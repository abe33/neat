Q = require 'q'
Neat = require '../neat'
{parser, uglify:pro} = require 'uglify-js'
{check, checkBuffer} = require './utils'

uglify = (buffer) ->
  checkBuffer buffer

  Q.fcall ->
    newBuffer = {}
    for path, content of buffer
      ast = parser.parse(content)
      ast = pro.ast_mangle(ast)
      ast = pro.ast_squeeze(ast)
      newBuffer[path.replace /\.js$/g, '.min.js'] = pro.gen_code(ast)

    newBuffer

module.exports = {uglify}
