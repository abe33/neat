Q = require 'q'
Neat = require '../neat'
CLIWatchPlugin = Neat.require 'tasks/watch/cli_watch_plugin'
commands = Neat.require 'utils/commands'
{puts, info, error, red, green} = Neat.require 'utils/logs'

class Lint extends CLIWatchPlugin
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

module.exports.lint = Lint
