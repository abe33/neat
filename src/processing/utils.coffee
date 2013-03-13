check = (arg, msg) ->
  throw new Error msg unless arg?

checkBuffer = (buffer) ->
  check buffer, 'Buffer must be set'
  throw new Error 'Buffer must be an object' if typeof buffer isnt 'object'

module.exports = {checkBuffer, check}
