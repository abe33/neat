fs = require 'fs'
Neat = require '../../../neat'
{queue} = require '../../../async'
{run} = require '../../../utils/commands'
{error, red, yellow, puts} = require '../../../utils/logs'

JASMINE = "#{Neat.neatRoot}/node_modules/.bin/jasmine-node"

module.exports = (config) ->
  config.engines.tests.jasmine = (name, test, callback) ->
    unless fs.existsSync JASMINE
      error """#{red "Can't find jasmine-node module"}

               Run #{yellow 'neat install'} to install the dependencies."""
      return callback?()

    args = ['.', '--color', '--coffee', '--test-dir']

    puts yellow "#{name.capitalize()} tests:"
    run JASMINE, args.concat("#{Neat.root}/#{test}"), callback
