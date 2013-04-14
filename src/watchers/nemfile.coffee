Q = require 'q'
Neat = require '../neat'
CLIWatchPlugin = Neat.require 'tasks/watch/cli_watch_plugin'
commands = Neat.require 'utils/commands'
{puts, info, error, red, green} = Neat.require 'utils/logs'

class Nemfile extends CLIWatchPlugin
  pathChanged: (path, action) -> =>
    @deferred = Q.defer()
    @process = commands.run 'neat', ['install'], (status) =>
      @deferred.resolve status
    @deferred.promise

module.exports.nemfile = Nemfile
