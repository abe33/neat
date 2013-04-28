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

  handleStatus: (status) ->
    if status is 0
      @watcher?.notifier.notify {
        success: true
        title: 'Jasmine'
        message: "All specs passed"
      }
      info green 'success'
    else
      @watcher?.notifier.notify {
        success: false
        title: 'Jasmine'
        message: "Some specs failed"
      }
      error red 'failure'

    @deferred.resolve status

  runAll: =>
    @deferred = Q.defer()
    puts yellow "run jasmine-node --coffee #{Neat.resolve 'test'}"
    jasmine = Neat.resolve 'node_modules/.bin/jasmine-node'
    args = ['--coffee', Neat.resolve 'test']
    @process = commands.run jasmine, args, (status) =>
      @handleStatus status

    @deferred.promise

  runJasmine: (path, paths) ->
    @deferred = Q.defer()

    if paths.length > 0
      puts yellow "run jasmine-node --coffee #{paths.join ' '}"
      jasmine = Neat.resolve 'node_modules/.bin/jasmine-node'
      @process = commands.run jasmine, ['--coffee'].concat(paths), (status) =>
        @handleStatus status
    else
      puts yellow "#{inverse ' NO SPEC '} No specs can be found for #{path}"
      @deferred.resolve 0
    @deferred.promise

module.exports.jasmine = Jasmine
