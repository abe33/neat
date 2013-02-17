check = (arg, msg) ->
  throw new Error msg unless arg?

checkBuffer = (buffer) ->
  throw new Error 'Buffer must be set' unless buffer?
  throw new Error 'Buffer must be an object' if typeof buffer isnt 'object'

module.exports = {checkBuffer, check}
