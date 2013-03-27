glob = require 'glob'
Q = require 'q'
Neat = require '../../neat'

class Watch
  constructor: (@regexp, @options={}, @block) ->
  match: (path) -> @regexp.test path
  outputPathsFor: (path) ->
    if @block?
      paths = @block.apply(null, [path].concat @regexp.exec path)
      paths = if typeof paths is 'string' then [paths] else paths
    else
      paths = [path]

    Q.all(@glob Neat.resolve(pattern) for pattern in paths)
    .then (paths) -> paths.flatten()

  glob: (pattern) ->
    defer = Q.defer()
    glob pattern, (err, paths) ->
      return defer.reject err if err?
      defer.resolve paths

    defer.promise

  toString: -> "[object Watch(#{@regexp})]"

module.exports = Watch
