# This file contains utilities to setup commands and generators.

{print} = require 'util'
{spawn} = require 'child_process'
{resolve} = require 'path'
{puts, error} = require './logs'
{Neat} = require '../neat'

## Private

##### decorate

# Decorates an object with the specified property and value.
decorate = (target, property, value) ->
  target[property] = value
  target

## Public

##### usages

# Defines the usages of the `target`.
#
#     usages 'foo', 'foo [arg]', -> console.log 'command called'
usages = (usages..., target) -> decorate target, 'usages', usages

##### aliases

# Defines the aliases of the `target`. Aliases are used to defined
# the keywords for which the command respond.
#
#     aliases 'f', 'foo', -> console.log 'command was called'
aliases = (aliases..., target) -> decorate target, 'aliases', aliases

##### describe

# Defines the description of the `target`.
#
#     describe 'This is a description', ->
#       console.log 'command was called'
describe = (description, target) -> decorate target, 'description', description

##### help

# Defines the help of the `target`.
#
#     help 'This is the help', ->
#       console.lgog 'command was called'
help = (help, target) -> decorate target, 'help', help

##### help

# Loads automatically the specified environment before triggering
# the `target`.
#
#     withEnv 'test', ->
#       console.log Neat.env.test? # true
withEnv = (env, target) -> ->
  Neat.setEnvironment env
  puts "Set environment #{env}".yellow if Neat.env.verbose
  target.apply null, arguments

##### run

# Runs the specified `command` with the passed-in `options`.
# The `callback` is called on the command exit if provided.
#
#     run 'coffee', ['-pcb', 'console.log "foo"'], ->
#       console.log 'command exited'
run = (command, options, callback) ->
  exe = spawn command, options
  exe.stdout.on 'data', (data) -> print data.toString()
  exe.stderr.on 'data', (data) -> print error data.toString()
  exe.on 'exit', (status) -> callback?()

module.exports = {
  aliases,
  decorate,
  describe,
  help,
  run,
  usages,
  withEnv,
}
