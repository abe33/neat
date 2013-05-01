Q = require 'q'

class WatchPlugin
  constructor: (@options, @watcher) -> @watches = []
  watch: (watch) -> @watches.push watch
  match: (path) -> @watches.some (w) -> w.match path
  watchesForPath: (path) -> @watches.select (w) -> w.match path
  outputPathsFor: (path) ->
    Q.all(w.outputPathsFor path for w in @watchesForPath(path))

  toString: -> @constructor.name

  #### Promise Returning Methods
  init: (watcher) -> null
  dispose: -> null
  # You can return a function instead of a promise to chain with
  # the previous promise in the queue.
  pathChanged: (path) -> => null
  runAll: -> null

  #### Other Abstract Methods
  kill: ->
  isPending: -> false

module.exports = WatchPlugin
