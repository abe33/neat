# @toc

fs = require 'fs'
path = require 'path'
Q = require 'q'
Neat = require '../neat'
utils = Neat.require 'utils/files'
{parallel, queue} = Neat.require 'async'
{check, checkBuffer} = require './utils'

exists = fs.exists or path.exists

##### readFiles
readFiles = (paths) ->
  defer = Q.defer()

  utils.readFiles paths, (err, res) ->
    return defer.reject(err) if err?
    defer.resolve res

  defer.promise

##### writeFiles
writeFiles = (buffer) ->
  checkBuffer buffer

  defer = Q.defer()
  error = null

  gen = (p, content) -> (callback) ->
    dir = path.resolve p, '..'
    utils.ensurePath dir, (err) ->
      return defer.reject err if err?
      fs.writeFile p, content, (err) ->
        return defer.reject err if err?
        callback?()

  queue (gen k,v for k,v of buffer), ->
    defer.resolve buffer

  defer.promise

##### processExtension
processExtension = (ext, process) ->
  check ext, 'Extension argument is mandatory'
  check process, 'Function argument is mandatory'

  return (buffer) ->
    checkBuffer buffer

    defer = Q.defer()

    filteredBuffer = buffer.select (k) -> path.extname(k) is ".#{ext}"
    buffer.destroy k for k of filteredBuffer
    process(Q.fcall -> filteredBuffer)
    .then (processedBuffer) ->
      defer.resolve buffer.merge processedBuffer
    .fail (err) ->
      defer.reject err

    defer.promise

##### join
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

##### relocate
relocate = (from, to) ->
  check from, 'From argument is mandatory'
  check to, 'To argument is mandatory'

  (buffer) ->
    checkBuffer buffer

    Q.fcall ->
      newBuffer = {}
      for p, content of buffer
        newPath = p.replace(from, to)
        newBuffer[newPath] = content
      newBuffer

##### remove
remove = (path) ->
  check path, 'Path argument is mandatory'

  (buffer) ->
    checkBuffer buffer

    defer = Q.defer()
    utils.rm Neat.rootResolve(path), (err) ->
      return defer.reject err if err?
      defer.resolve buffer

    defer.promise

##### fileHeader
fileHeader = (header) ->
  check header, 'Header argument is mandatory'

  (buffer) ->
    checkBuffer buffer

    Q.fcall ->
      newBuffer = {}

      newBuffer[file] = "#{header}\n#{content}" for file, content of buffer
      newBuffer

##### fileFooter
fileFooter = (footer) ->
  check footer, 'Footer argument is mandatory'

  (buffer) ->
    checkBuffer buffer

    Q.fcall ->
      newBuffer = {}

      newBuffer[file] = "#{content}\n#{footer}\n" for file, content of buffer

      newBuffer

module.exports = {
  readFiles
  writeFiles
  processExtension
  join
  fileHeader
  fileFooter
  relocate
  remove
}
