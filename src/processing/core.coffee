fs = require 'fs'
path = require 'path'
Q = require 'q'
Neat = require '../neat'
utils = Neat.require 'utils/files'

exists = fs.exists or path.exists

readFiles = (paths) ->
  defer = Q.defer()

  utils.readFiles paths, (err, res) ->
    return defer.reject(err) if err?
    defer.resolve res

  defer.promise

module.exports = {readFiles}
