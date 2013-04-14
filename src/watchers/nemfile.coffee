Q = require 'q'
Neat = require '../neat'
WatchPlugin = Neat.require 'tasks/watch/watch_plugin'
commands = Neat.require 'utils/commands'
{puts, info, error, red, green} = Neat.require 'utils/logs'

class Nemfile extends WatchPlugin
  pathChanged: (path, action) -> =>
    @deferred = Q.defer()
    @process = commands.run 'neat', ['install'], (status) =>
      @deferred.resolve status
    @deferred.promise

  kill: (signal) ->
    @process.kill signal
    @deferred.resolve 1


module.exports.nemfile = Nemfile
