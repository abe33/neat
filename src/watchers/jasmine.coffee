Q = require 'q'
Neat = require '../neat'
WatchPlugin = Neat.require 'tasks/watch/watch_plugin'
commands = Neat.require 'utils/commands'
{puts, info, error, red, green} = Neat.require 'utils/logs'

class Jasmine extends WatchPlugin
  pathChanged: (path, action) -> =>
    @outputPathsFor(path).then (paths) => @runJasmine paths.flatten()

  runJasmine: (paths) ->
    defer = Q.defer()

    if paths.length > 0
      jasmine = Neat.resolve 'node_modules/.bin/jasmine-node'
      commands.run jasmine, ['--coffee'].concat(paths), (status) ->
        if status is 0
          info green 'success'
        else
          error red 'failure'
        defer.resolve status
    else
      defer.resolve 0
    defer.promise

module.exports.jasmine = Jasmine
