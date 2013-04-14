Q = require 'q'
Neat = require '../neat'
CLIWatchPlugin = Neat.require 'tasks/watch/cli_watch_plugin'
commands = Neat.require 'utils/commands'

class PackageJson extends CLIWatchPlugin
  pathChanged: (path, action) -> =>
    @deferred = Q.defer()
    @process = commands.run 'neat', ['generate', 'package.json'], (status) =>
      @deferred.resolve status
    @deferred.promise

module.exports.package_json = PackageJson
