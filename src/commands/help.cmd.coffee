fs = require 'fs'
{resolve} = require 'path'
{Neat} = require '../env'

utils = resolve Neat.neatRoot, "lib/utils"

{findSiblingFile} = require resolve utils, "files"
{render, renderSync} = require resolve utils, "templates"
{puts, error, warn, missing, neatBroken} = require resolve utils, "logs"

cmds = resolve utils, "commands"
{run, aliases, usages, describe, help:withHelp} = require cmds

help = (pr, commands) ->
  return puts error "No program provided to help" unless pr?
  return puts error "No commands map provided" unless commands?

  aliases 'h', 'help',
  usages 'neat help [command]',
  describe 'Display the help of the specified command',
  withHelp """This is the help""",
  f = (command, args..., cb) ->
    args.push cb if typeof cb isnt 'function'

    if command? and typeof command is 'string'
      cmd = commands[command]
      return puts(missing "Command #{command}") and cb?() unless cmd?
    else
      list = {}
      list[c.aliases.join ", "] = c for k,c of commands

      listContext =
        list: list
        title: "Commands:"

      cmd =
        usages: ['neat [command] [args]...']
        description: renderSync(resolve(__dirname, "help/_neat")).yellow
        help: renderSync resolve(__dirname, "help/_list"), listContext

    output = (err, res) -> puts(res) and cb?()

    if typeof cmd.help is 'function'
      render __filename, cmd.help.apply(null, args), output
    else
      render __filename, cmd, output

module.exports = {help}
