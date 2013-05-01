# This file contains utilities to setup commands and generators.
# @toc

{spawn} = require 'child_process'
{resolve} = require 'path'
{puts, print, error} = require './logs'
Neat = require '../neat'
_ = Neat.i18n.getHelper()

#### Private

##### decorate

# Decorates an object with the specified property and value.
decorate = (target, property, value) ->
  target[property] = value
  target

#### Public

##### aliases

# Defines the aliases of the `target`. Aliases are used to defined
# the keywords for which the command respond.
#
#     aliases 'f', 'foo', -> console.log 'command was called'
aliases = (aliases..., target) -> decorate target, 'aliases', aliases

##### asyncErrorTrap

# Trap error returned by asynchronous function in the callback arguments
# by generating a callback wrapper that will call the callback only if
# no errors was received. The error argument is not passed to the callback.
#
#     fs.readFile "/path/to/file", asyncErrorTrap (content) ->
#       # do something with content
#
# Optionally, a function can be passed as first argument to receive the error,
# typically the final callback you'll trigger in your async process.
#
#     asyncFunction = (callback) ->
#       path = "/path/to/file"
#       fs.readFile path, asyncErrorTrap callback, (content) ->
#         # do something with content
#         callback? null, content
#
# If an error occurs, the callback is automatically triggered with the error
# as the first argument, following in that regard the pattern of node's async
# functions. You should take care to pass your results after a null argument,
# allowing callback to use the following pattern:
#
#     asyncFunction asyncErrorTrap (results...) -> # etc...
asyncErrorTrap = (errCallback, callback) -> (err, args...) ->
  [errCallback, callback] = [callback, errCallback] unless callback?
  if err?
    if errCallback? then return errCallback err else return err
  callback?.apply null, args

##### deprecated

deprecated = (message, target) -> decorate target, 'deprecated', message

##### describe

# Defines the description of the `target`.
#
#     describe 'This is a description', ->
#       console.log 'command was called'
describe = (description, target) -> decorate target, 'description', description

##### environment

# Loads automatically the specified environment before triggering
# the `target`.
#
#     environment 'test', ->
#       console.log Neat.env.test? # true
environment = (env, target) -> decorate target, 'environment', env

##### hashArguments

# Converts an array of strings with a form such as `key:value`
# in an object with the corresponding properties.
#
# These are supposed to come from a command line input such as
# some limitations occurs:
#
#   1. There cannot be any spaces between the key, the colon and the value.
#   2. String values that will contains spaces must be wrapped into `"` or `'`.
#   3. There cannot be any spaces between the element of an array and the
#      commas before and after it.
#
# For instance, in the following command line input:
#
#     neat g project dummy author:"John Doe" keywords:foo,bar
#
# The hash arguments, once parsed by the `hashArguments` function,
# will look like:
#
#     {author: 'John Doe', keywords: ['foo', 'bar']}
#
# Basic types such `String`, `Number`, `Boolean` and `Array` are supported
# as arguments value:
#
#     integer:0                  # 0
#     float:0.5                  # 0.5
#     string:foo                 # 'foo'
#     stringWithSpace:"foo bar"  # 'foo bar'
#     booleans:yes               # true
#     arrays:foo,10,false        # ['foo', 10, false]
#
# As you may have notice, booleans are available with various aliases:
#
#   * `true`: `true`, `on`, `yes`
#   * `false`: `false`, `off`, `no`
hashArguments = (ary...) ->
  ary = ary.flatten()
  hash = {}
  parse = (v) ->
    switch true
      when /^(false|no|off)$/.test v then false
      when /^(true|yes|on)$/.test v then true
      when /^(-*)\d+$/g.test v then parseInt v
      when /^(-*)\d+\.\d+$/g.test v then parseFloat v
      when ',' in String(v) then parse sub for sub in v.split ','
      else v.replace /^('|")|('|")$/g, ''

  for expr in ary
    (hash[k] = true; continue) unless ':' in expr
    [k,v] = expr.split ':'
    if v.empty()
      throw new Error _('neat.commands.invalid_arguments', expression: expr)

    hash[k] = parse v

  hash

##### help

# Defines the help of the `target`.
#
#     help 'This is the help', ->
#       console.log 'command was called'
help = (help, target) -> decorate target, 'help', help

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

  throw new Error _('neat.tasks.no_name') unless name?
  throw new Error _('neat.tasks.no_action') unless action?

  action.environment = environment
  action.description = description

  taskAction = ->
    {action, environment} = options
    Neat.defaultEnvironment = environment if environment?
    Neat.initEnvironment ->
      Neat.beforeTask.dispatch -> action (status) ->
        Neat.afterTask.dispatch status, ->
          process.exit status

  task name, description, taskAction
  action

##### neatTaskAlias
neatTaskAlias = (source, alias, environment) ->
  neatTask
    name: alias
    description: _('neat.tasks.alias', task: source)
    environment: environment
    action: (callback) ->
      task = Neat.task(source)
      task callback

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
  exe

##### usages

# Defines the usages of the `target`.
#
#     usages 'foo', 'foo [arg]', -> console.log 'command called'
usages = (usages..., target) -> decorate target, 'usages', usages

module.exports = {
  aliases
  asyncErrorTrap
  decorate
  describe
  deprecated
  environment
  hashArguments
  help
  neatTask
  neatTaskAlias
  run
  usages
}
