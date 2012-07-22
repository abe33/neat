path = require 'path'
Neat = require '../../../neat'
{run} = require '../../../utils/commands'

JASMINE = "#{Neat.root}/node_modules/.bin/jasmine-node"

module.exports = (config) ->
  config.engines.tests.jasmine = (callback) ->
    unless path.existsSync JASMINE
      msg = """#{red "Can't find jasmine-node module"}

               Run #{yellow 'neat install'} to install the dependencies."""
      return callback? new Error msg

    args = ['.', '--color', '--coffee', '--test-dir', "#{Neat.root}/test/spec"]
    run JASMINE, args, callback
