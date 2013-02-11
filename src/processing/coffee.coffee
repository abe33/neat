Q = require 'q'
{compile:coffee} = require 'coffee-script'

compile = (options) -> (buffer) ->
  Q.fcall ->
    newBuffer = {}
    try
      for path, content of buffer
        newBuffer[path.replace '.coffee', '.js'] = coffee content, options
    catch e
      throw new Error "In file '#{path}': #{e.message}"

    newBuffer

module.exports = {compile}
