# This file contains utilities to setup commands and generators.
# @toc

{spawn} = require 'child_process'
{resolve} = require 'path'
{puts, print, error} = require './logs'
Neat = require '../neat'

#### Private

##### decorate

# Decorates an object with the specified property and value.
decorate = (target, property, value) ->
  target[property] = value
  target

#### Public

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
#       console.log 'command was called'
help = (help, target) -> decorate target, 'help', help

##### environment

# Loads automatically the specified environment before triggering
# the `target`.
#
#     environment 'test', ->
#       console.log Neat.env.test? # true
environment = (env, target) -> decorate target, 'environment', env

##### run

# Runs the specified `command` with the passed-in `params`.
# The `callback` is called on the command exit if provided.
#
#     run 'coffee', ['-pcb', 'console.log "foo"'], (status) ->
#       console.log "command exited with status #{status}"
#
# You can also prevent the function to print the command output
# or register your own output listeners using the `options` hash.
#
#     options =
#       noStdout: true
#       stdError: (data) -> # Do something with data
#
#     run 'coffee', ['src/*'], options, (status) ->
#       console.log "command exited with status #{status}"
run = (command, params, options, callback) ->
  [callback, options] = [options, callback] if typeof options is 'function'

  exe = spawn command, params

  unless options?.noStdout?
    exe.stdout.on 'data', options?.stdout || (data) -> print data.toString()
  unless options?.noStderr?
    exe.stderr.on 'data',  options?.stderr || (data) -> print data.toString()

  exe.on 'exit', (status) -> callback? status

##### neatTask

# Register a cake task that will run through Neat.
#
#     exports.taskName = neatTask
#       name: 'taskName'                # required
#       description: 'task description' # optional
#       environment: 'production'       # optional
#       action: -> ...                  # required
neatTask = (options) ->
  {name, action, description, environment} = options

  throw new Error "Tasks must have a name" unless name?
  throw new Error "Tasks must have an action" unless action?

  taskAction = ->
    {action, environment} = options
    Neat.defaultEnvironment = environment if environment?
    Neat.initEnvironment()
    action()

  task name, description, taskAction
  action

##### asyncErrorTrap

# Trap error returned by asynchronous function in the callback arguments
# by generating a callback wrapper that will call the callback only if
# no errors was received. The error arguments isn't passed to the callback.
#
#     fs.readFile "/path/to/file", asyncErrorTrap (content) ->
#       # do something with content
asyncErrorTrap = (callback) -> (err, args...) ->
  return error "#{err.stack}\n" if err?
  callback?.apply null, args

module.exports = {
  aliases,
  asyncErrorTrap,
  decorate,
  describe,
  environment,
  help,
  neatTask,
  run,
  usages,
}
