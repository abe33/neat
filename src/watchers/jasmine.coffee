Q = require 'q'
Neat = require '../neat'
CLIWatchPlugin = Neat.require 'tasks/watch/cli_watch_plugin'
commands = Neat.require 'utils/commands'
{
  puts, magenta, yellow, info,
  error, red, green, inverse
} = Neat.require 'utils/logs'

class Jasmine extends CLIWatchPlugin
  pathChanged: (path, action) -> =>
    @outputPathsFor(path).then (paths) => @runJasmine path, paths.flatten()

  runJasmine: (path, paths) ->
    @deferred = Q.defer()

    if paths.length > 0
      puts yellow "run jasmine-node --coffee #{paths.join ' '}"
      jasmine = Neat.resolve 'node_modules/.bin/jasmine-node'
      @process = commands.run jasmine, ['--coffee'].concat(paths), (status) =>
        if status is 0
          info green 'success'
        else
          error red 'failure'
        @deferred.resolve status
    else
      puts yellow "#{inverse ' NO SPEC '} No specs can be found for #{path}"
      @deferred.resolve 0
    @deferred.promise

module.exports.jasmine = Jasmine
