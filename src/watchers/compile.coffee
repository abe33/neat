Q = require 'q'
Neat = require '../neat'
WatchPlugin = Neat.require 'tasks/watch/watch_plugin'
commands = Neat.require 'utils/commands'

class Compile extends WatchPlugin
  pathChanged: (path, action) -> =>
    @deferred = Q.defer()
    @process = commands.run 'cake', ['compile'], (status) =>
      @deferred.resolve status
    @deferred.promise

  kill: (signal) ->
    @process.kill signal
    @deferred.resolve 1

module.exports.compile = Compile
