Q = require 'q'

class WatchPlugin
  constructor: (@options) -> @watches = []
  watch: (watch) -> @watches.push watch
  match: (path) -> @watches.some (w) -> w.match path
  watchesForPath: (path) -> @watches.select (w) -> w.match path
  outputPathsFor: (path) ->
    Q.all(w.outputPathsFor path for w in @watchesForPath(path))

  #### Promise Returning Methods
  init: (watcher) -> null
  dispose: -> null
  pathChanged: (path) -> null

module.exports = WatchPlugin
