fs = require 'fs'
path = require 'path'
Q = require 'q'
Neat = require '../neat'
utils = Neat.require 'utils/files'
{parallel} = Neat.require 'async'
{check, checkBuffer} = require './utils'

exists = fs.exists or path.exists

readFiles = (paths) ->
  defer = Q.defer()

  utils.readFiles paths, (err, res) ->
    return defer.reject(err) if err?
    defer.resolve res

  defer.promise

writeFiles = (buffer) ->
  checkBuffer buffer

  defer = Q.defer()
  error = null

  gen = (p, content) -> (callback) ->
    dir = path.resolve p, '..'
    utils.ensurePath dir, (err) ->
      fs.writeFile p, content, (err) ->
        error = err if err?
        callback?()

  parallel (gen k,v for k,v of buffer), ->
    return defer.reject error if error?
    defer.resolve buffer

  defer.promise

processExtension = (ext, process) ->
  check ext, 'Extension argument is mandatory'
  check process, 'Function argument is mandatory'

  (buffer) ->
    checkBuffer buffer

    defer = Q.defer()

    filteredBuffer = buffer.select (k) -> path.extname(k) is ".#{ext}"
    buffer.destroy k for k of filteredBuffer
    process(filteredBuffer)
    .then (processedBuffer) ->
      defer.resolve buffer.merge processedBuffer
    .fail (err) ->
      defer.reject err

    defer.promise

join = (fileName) ->
  check fileName, 'File name argument is mandatory'

  (buffer) ->
    checkBuffer buffer

    Q.fcall ->
      newBuffer = {}
      newContent = []
      newContent.push v for k,v of buffer
      newBuffer[fileName] = newContent.join('\n')
      newBuffer

relocate = (from, to) ->
  check from, 'From argument is mandatory'
  check to, 'To argument is mandatory'



module.exports = {readFiles, writeFiles, processExtension, join, relocate}
