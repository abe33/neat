Q = require 'q'
Neat = require '../neat'
WatchPlugin = Neat.require 'tasks/watch/watch_plugin'
commands = Neat.require 'utils/commands'

class Lint extends WatchPlugin
  init: (watcher) ->
    @runCakeLint() if @options.runAllOnStart

  pathChanged: (path, action) -> =>
    @outputPathsFor(path).then (paths) => @runLint paths.flatten()

  runCakeLint: (paths) ->
    defer = Q.defer()
    commands.run 'cake', ['lint'], (status) ->
      defer.resolve status
    defer.promise

  runLint: (paths) ->
    defer = Q.defer()
    coffeelint = Neat.resolve 'node_modules/.bin/coffeelint'
    commands.run coffeelint, paths, (status) -> defer.resolve status
    defer.promise

module.exports.lint = Lint
