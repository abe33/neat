fs = require 'fs'
path = require 'path'
Q = require 'q'
Neat = require '../neat'
utils = Neat.require 'utils/files'
{parallel} = Neat.require 'async'

exists = fs.exists or path.exists

readFiles = (paths) ->
  defer = Q.defer()

  utils.readFiles paths, (err, res) ->
    return defer.reject(err) if err?
    defer.resolve res

  defer.promise

writeFiles = (buffer) ->
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


module.exports = {readFiles, writeFiles}
