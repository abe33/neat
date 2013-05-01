Q = require 'q'
Neat = require '../neat'
uglifier = require 'uglify-js'
{check, checkBuffer} = require './utils'

uglify = (buffer) ->
  checkBuffer buffer

  Q.fcall ->
    newBuffer = {}
    for path, content of buffer
      output = path.replace /\.js$/g, '.min.js'
      newBuffer[output] = uglifier.minify content, fromString: true

    newBuffer
  .fail (err) ->
    console.log err.message
    console.log err.stack

module.exports = {uglify}
