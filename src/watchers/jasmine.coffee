Q = require 'q'
Neat = require '../neat'
WatchPlugin = Neat.require 'tasks/watch/watch_plugin'
commands = Neat.require 'utils/commands'
{
  puts, magenta, yellow, info,
  error, red, green, inverse
} = Neat.require 'utils/logs'

class Jasmine extends WatchPlugin
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

  kill: (signal) ->
    @process.kill signal
    @deferred.resolve 1

  isPending: -> @deferred? and @deferred.promise.isPending()

module.exports.jasmine = Jasmine
