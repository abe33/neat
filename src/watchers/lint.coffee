Q = require 'q'
Neat = require '../neat'
WatchPlugin = Neat.require 'tasks/watch/watch_plugin'
commands = Neat.require 'utils/commands'
{puts, info, error, red, green} = Neat.require 'utils/logs'

class Lint extends WatchPlugin
  init: (watcher) ->
    @runCakeLint() if @options.runAllOnStart

  pathChanged: (path, action) -> =>
    @outputPathsFor(path).then (paths) => @runLint paths.flatten()

  runCakeLint: (paths) ->
    @deferred = Q.defer()
    @process = commands.run 'cake', ['lint'], (status) =>
      @deferred.resolve status
    @deferred.promise

  runLint: (paths) ->
    @deferred = Q.defer()
    coffeelint = Neat.resolve 'node_modules/.bin/coffeelint'
    @process = commands.run coffeelint, paths, (status) =>
      if status is 0
        info green 'success'
      else
        error red 'failure'
      @deferred.resolve status
    @deferred.promise

  kill: (signal) ->
    @process.kill signal
    @deferred.resolve 1

  isPending: -> @deferred? and @deferred.promise.isPending()

module.exports.lint = Lint
