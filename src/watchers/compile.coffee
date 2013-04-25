Q = require 'q'
Neat = require '../neat'
CLIWatchPlugin = Neat.require 'tasks/watch/cli_watch_plugin'
commands = Neat.require 'utils/commands'

class Compile extends CLIWatchPlugin
  pathChanged: (path, action) -> =>
    @deferred = Q.defer()
    @process = commands.run 'cake', ['build'], (status) =>
      @deferred.resolve status
    @deferred.promise

module.exports.compile = Compile
