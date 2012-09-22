# This file contains the main initialization of the `neat` command line tool.
#
# This file is loaded by the bin bootstrap. If the `neat` command line tool
# is run inside a Neat project, the local installation files will be used
# if they are available.
# @toc

#### Global Requires
fs = require 'fs'
pr = require 'commander'
{spawn} = require 'child_process'
{resolve} = require 'path'

# The core module is loaded before any other *local* modules.
core = require './core'
{puts, print, error, missing} = require "./utils/logs"
# The Neat environment is loaded.
Neat = require './neat'
_ = Neat.i18n.getHelper()

#### Commands Registration

# Commands are defined by the `CLICommand` interface.
#
# Commands are functions with a property `aliases` which
# is an array of strings.
CLICommand = require './core/interfaces/cli_command'

# All the commands are required through this single call.
#
# The `index` of the `commands` directory contains a script that
# merge all the commands defined in all of the following places:
#
#  1. The Neat installation.
#  2. All the Neat projects in installed modules.
#  3. The project `commands` directory.
commands  = require "./commands"

# Generates a function that execute the passed-in command after initializing
# the Neat environment.
commandTrigger = (c) -> (args..., callback) ->
  if typeof callback isnt 'function'
    args.push callback
    callback = null

  Neat.defaultEnvironment = c.environment if c.environment?
  Neat.initEnvironment ->
    Neat.beforeCommand.dispatch ->
      c.apply null, args.concat (err) ->
        if err?
          error _('neat.errors.error', msg: err.message, stack: err.stack)
        Neat.afterCommand.dispatch callback

# The commands will be register in a hash with their aliases as keys.
cmdMap = {}
register = (k, c) ->
  # Passed-in commands are duck tested against the `CLICommand` interface.
  unless c.quacksLike CLICommand
    return error _('neat.commands.invalid_command',
                   command: _('neat.commands.no_register',
                              command: k).red)

  for alias in c.aliases
    pr.command(alias).description(c.description).action commandTrigger c
    cmdMap[k] = c

#### Neat CLI

# The commander program is initialized
pr.version(Neat.meta.version)

# All the commands are registered.
register(k, g pr, cmdMap) for k,g of commands

# Handler for invalid commands.
pr.command("*").action (command) ->
  Neat.initEnvironment ->
    error _('neat.commands.missing_command',
            missing: missing _('neat.commands.command',
                               command: command))

# Starts commander parsing.
pr.parse(process.argv)

# Nothing was triggered by commander, the help is displayed.
{help} = cmdMap
commandTrigger(help)() if pr.args.length is 0 and help?
