Q = require 'q'
Neat = require '../neat'
CLIWatchPlugin = Neat.require 'tasks/watch/cli_watch_plugin'
commands = Neat.require 'utils/commands'
{puts, info, error, red, green} = Neat.require 'utils/logs'

class Lint extends CLIWatchPlugin
  init: (watcher) ->
    @runAll() if @options.runAllOnStart

  pathChanged: (path, action) -> =>
    @outputPathsFor(path).then (paths) => @runLint paths.flatten()

  handleStatus: (status) ->
    if status is 1
      @watcher?.notifier.notify {
        success: false
        title: 'Lint'
        message: "Lint failed"
      }
    else
      @watcher?.notifier.notify {
        success: true
        title: 'Lint'
        message: "Lint successful"
      }
    @deferred.resolve status

  runAll: (paths) =>
    @deferred = Q.defer()
    @process = commands.run 'cake', ['lint'], (status) =>
      @handleStatus status

    @deferred.promise

  runLint: (paths) ->
    @deferred = Q.defer()
    coffeelint = Neat.resolve 'node_modules/.bin/coffeelint'
    @process = commands.run coffeelint, paths, (status) =>
      @handleStatus status

    @deferred.promise

module.exports.lint = Lint
