path = require 'path'
Neat = require '../../../neat'
{queue} = require '../../../async'
{run} = require '../../../utils/commands'
{error, red, yellow, puts} = require '../../../utils/logs'

JASMINE = "#{Neat.neatRoot}/node_modules/.bin/jasmine-node"

module.exports = (config) ->
  config.engines.tests.jasmine = (callback) ->
    unless path.existsSync JASMINE
      error """#{red "Can't find jasmine-node module"}

               Run #{yellow 'neat install'} to install the dependencies."""
      return callback?()

    paths =
      units: 'test/units'
      functionals: 'test/functionals'
      integrations: 'test/integrations'

    args = ['.', '--color', '--coffee', '--test-dir']

    runTest = (name, test) -> (callback) ->
      puts yellow "#{name.capitalize()} tests:"
      run JASMINE, args.concat("#{Neat.root}/#{test}"), (status) ->
        callback?()

    queue (runTest k,v for k,v of paths), ->
      callback?()
