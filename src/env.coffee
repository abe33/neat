# This file contains the main initialization of the `neat` command line tool.
#
# This file is loaded by the bin bootstrap. If the `neat` command line tool
# is run inside a Neat project, the local installation files will be used
# if they are available.

#### Global Requires
fs = require 'fs'
pr = require 'commander'
{print} = require 'util'
{spawn} = require 'child_process'
{resolve} = require 'path'

# The core module is loaded before any other *local* modules.
core = require resolve __dirname, 'core'
{puts, error, missing} = require resolve __dirname, "utils/logs"
# The Neat environment is loaded.
Neat = require resolve __dirname, 'neat'
Neat.initEnvironment()

#### Commands Registration

# All the commands are required through this single call.
#
# The `index` of the `commands` directory contains a script that
# merge all the commands defined in all of the following places:
#
#  1. The Neat installation.
#  2. All the Neat projects in installed modules.
#  3. The project `commands` directory.
commands  = require resolve __dirname, "commands"

# The commands will be register in a hash with their aliases as keys.
cmdMap = {}
register = (k, c) ->
  # Commands must have aliases.
  unless c.aliases?
    return print "Can't register command #{k} due to missing aliases\n".red

  for alias in c.aliases
    pr.command(alias).description(c.description).action(c)
    cmdMap[k] = c

#### Neat CLI

# The commander program is initialized
pr.version(Neat.meta.version)

# All the commands are registered.
register(k, g pr, cmdMap) for k,g of commands

# Handler for invalid commands.
pr.command("*").action (command) ->
  puts """#{missing "Command #{command}"}

          Try `neat help` for a list of the available commands."""

# Starts commander parsing.
pr.parse(process.argv)

# Nothing was triggered by commander, the help is displayed.
{help} = cmdMap
help() if pr.args.length is 0 and help?
