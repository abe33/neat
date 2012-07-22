path = require 'path'
Neat = require '../../../neat'
{run} = require '../../../utils/commands'
{error, red, yellow} = require '../../../utils/logs'

JASMINE = "#{Neat.root}/node_modules/.bin/jasmine-node"

module.exports = (config) ->
  config.engines.tests.jasmine = (callback) ->
    unless path.existsSync JASMINE
      error """#{red "Can't find jasmine-node module"}

               Run #{yellow 'neat install'} to install the dependencies."""
      return callback?()

    args = ['.', '--color', '--coffee', '--test-dir', "#{Neat.root}/test/spec"]
    run JASMINE, args, (status) ->
      callback?()
