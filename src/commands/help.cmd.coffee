fs = require 'fs'
{resolve} = require 'path'
Neat = require '../neat'

utils = resolve Neat.neatRoot, "lib/utils"

{render, renderSync} = require resolve utils, "templates"
{puts, error, warn, missing, neatBroken} = require resolve utils, "logs"

cmds = resolve utils, "commands"
{run, aliases, usages, describe, help:withHelp, environment} = require cmds

help = (pr, commands) ->
  return error "No program provided to help" unless pr?
  return error "No commands map provided" unless commands?

  aliases 'h', 'help',
  environment 'production',
  usages 'neat help [command]',
  describe 'Display the help of the specified [command]',
  withHelp """Display the help of the specified [command].""",
  f = (command, args..., cb) ->
    args.push cb if typeof cb isnt 'function'

    if command? and typeof command is 'string'
      cmd = commands[command]
      return error(missing "Command #{command}") and cb?() unless cmd?
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

    output = (err, res) ->
      console.log(res)
      cb?()

    if typeof cmd.help is 'function'
      render __filename, cmd.help.apply(null, args), output
    else
      render __filename, cmd, output

module.exports = {help}
