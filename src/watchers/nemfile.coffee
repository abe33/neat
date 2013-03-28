Q = require 'q'
Neat = require '../neat'
WatchPlugin = Neat.require 'tasks/watch/watch_plugin'
commands = Neat.require 'utils/commands'
{puts, info, error, red, green} = Neat.require 'utils/logs'

class Nemfile extends WatchPlugin
  pathChanged: (path, action) -> =>
    defer = Q.defer()
    commands.run 'neat', ['install'], (status) ->
      defer.resolve status
    defer.promise

module.exports.nemfile = Nemfile
