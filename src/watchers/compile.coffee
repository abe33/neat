Q = require 'q'
Neat = require '../neat'
WatchPlugin = Neat.require 'tasks/watch/watch_plugin'
commands = Neat.require 'utils/commands'

class Compile extends WatchPlugin
  pathChanged: (path, action) -> =>
    defer = Q.defer()
    commands.run 'cake', ['compile'], (status) -> defer.resolve status
    defer.promise

module.exports.compile = Compile
