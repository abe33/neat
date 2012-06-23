
fs = require 'fs'
{resolve} = require 'path'
{Neat} = require '../neat'

utils = resolve Neat.neatRoot, "lib/utils"

{puts, error, warn, missing, neatBroken} = require resolve utils, "logs"
{run, aliases, describe, withEnv} = require resolve utils, "commands"

dummy = (pr) ->
  return puts error "No program provided to dummy" unless pr?

  aliases 'dummy',
  describe 'Installs all the dependencies listed in the `Nemfile`',
  withEnv 'foo',
  f = (cb)->
    puts "foooOOO"

module.exports = {dummy}

