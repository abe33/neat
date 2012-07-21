path = require 'path'
Neat = require '../neat'
{run, neatTask} = require '../utils/commands'
{error, info, green, red, yellow,puts} = require '../utils/logs'

JASMINE = './node_modules/.bin/jasmine-node'

exports.test = neatTask
  name:'test'
  description: 'Tests the sources'
  action: (callback) ->
    unless path.existsSync JASMINE
      msg = """#{red "Can't find jasmine-node module"}

               Run #{yellow 'neat install'} to install the dependencies."""
      return error msg

    Neat.task('compile') (status) ->
      if status is 0
        args = [
          '.',
          '--color',
          '--coffee',
          '--test-dir',
          "#{Neat.root}/test/spec"
        ]
        run JASMINE, args, callback
      else
        puts
        callback?()
