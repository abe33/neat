pathmod = require 'path'

generator = (fileSystem) ->
  existsSync = (path) -> fileSystem.exists path
  exists = (path, callback) -> callback? fileSystem.exists path

  {
    existsSync,
    exists,
  }

module.exports = generator
