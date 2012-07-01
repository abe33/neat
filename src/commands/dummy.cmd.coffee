
fs = require 'fs'
{resolve} = require 'path'
Neat = require '../neat'

utils = resolve Neat.neatRoot, "lib/utils"

{
  puts,
  print,
  error,
  warn,
  missing,
  neatBroken,
  logger,
} = require resolve utils, "logs"
{run, aliases, describe, withEnv} = require resolve utils, "commands"

dummy = (pr) ->
  return error "No program provided to dummy" unless pr?

  aliases 'dummy',
  describe "I'am a dummy command that print some stuff",
  withEnv 'foo',
  f = (cb)->
    print ".".red, 0
    print ".".yellow, 1
    print ".".green, 2
    print ".".cyan, 3
    print ".".blue, 4
    puts "."
    puts "a second line", 1
    console.log logger.stack

module.exports = {dummy}

