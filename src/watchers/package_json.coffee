Q = require 'q'
Neat = require '../neat'
WatchPlugin = Neat.require 'tasks/watch/watch_plugin'
commands = Neat.require 'utils/commands'

class PackageJson extends WatchPlugin
  pathChanged: (path, action) -> =>
    defer = Q.defer()
    commands.run 'neat', ['generate', 'package.json'], (status) ->
      defer.resolve status
    defer.promise

module.exports.package_json = PackageJson
