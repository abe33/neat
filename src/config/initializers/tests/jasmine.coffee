fs = require 'fs'
path = require 'path'
Neat = require '../../../neat'
{queue} = require '../../../async'
{run} = require '../../../utils/commands'
{error, red, yellow, puts} = require '../../../utils/logs'

existsSync = fs.existsSync or path.existsSync

paths = Neat.paths.map (p) -> "#{p}/node_modules/.bin/jasmine-node"
paths = paths.filter (p) -> existsSync p

JASMINE = paths[0]

module.exports = (config) ->
  config.engines.tests.jasmine = (name, test, callback) ->
    unless existsSync JASMINE
      error """#{red "Can't find jasmine-node module"}

               Run #{yellow 'neat install'} to install the dependencies."""
      return callback?()

    testDir = "#{Neat.root}/#{test}"
    return callback? 0 unless existsSync testDir

    args = ['.', '--color', '--coffee', '--test-dir']

    puts yellow "#{name.capitalize()} tests:"
    run JASMINE, args.concat(testDir), callback
