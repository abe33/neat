Q = require 'q'
Neat = require '../neat'
CLIWatchPlugin = Neat.require 'tasks/watch/cli_watch_plugin'
commands = Neat.require 'utils/commands'

class PackageJson extends CLIWatchPlugin
  pathChanged: (path, action) -> =>
    @deferred = Q.defer()
    @process = commands.run 'neat', ['generate', 'package.json'], (status) =>
      @deferred.resolve status
      if status is 0
        @watcher?.notifier.notify {
          success: true
          title: 'package.json'
          message: "File generated successfully"
        }
      else
        @watcher?.notifier.notify {
          success: false
          title: 'package.json'
          message: "File generation failed"
        }

    @deferred.promise

module.exports.package_json = PackageJson
