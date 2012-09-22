fs = require 'fs'
{resolve} = require 'path'
Neat = require '../neat'

{render, renderSync} = Neat.require "utils/templates"
{puts, error, warn, missing} = Neat.require "utils/logs"
{
  run, aliases, usages, describe, help:withHelp, environment
} = Neat.require 'utils/commands'
_ = Neat.i18n.getHelper()

help = (pr, commands) ->
  throw new Error _('neat.commands.no_program', command: 'help') unless pr?
  throw new Error _('neat.commands.no_commands') unless commands?

  aliases 'h', 'help',
  environment 'production',
  usages 'neat help [command]',
  describe _('neat.commands.help.description'),
  withHelp _('neat.commands.help.description'),
  f = (command, args..., cb) ->
    args.push cb if typeof cb isnt 'function'

    if command? and typeof command is 'string'
      cmd = commands[command]
      unless cmd?
        return cb? new Error missing _('neat.commands.command',{command})
    else
      list = {}
      list[c.aliases.join ", "] = c for k,c of commands

      listContext =
        list: list
        title: _('neat.commands.help.help_list_title')

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
