Neat = require '../neat'

{error, puts} = Neat.require 'utils/logs'
{aliases, describe, environment, usages} = Neat.require 'utils/commands'
{namespace} = Neat.require 'utils/exports'
{first, last, length, property} = Neat.require 'utils/mappers'
_ = Neat.i18n.getHelper()

list = (pr, commands) ->
  unless pr?
    throw new Error _('neat.commands.no_program', command: 'list')

  aliases 'list',
  describe _('neat.commands.list.description'),
  environment 'production',
  cmd = (cb)->
    t = commands.flatten().group(2)

    c1 = t.map(first length()).max() + 4
    c2 = t.map(last property 'environment', length()).compact().max() + 4
    c3 = t.map(last property 'aliases', (o) -> String(o).length)
          .compact()
          .max() + 4

    command = _('neat.commands.list.headers.command').left c1
    environment = _('neat.commands.list.headers.environment').left c2
    aliases = _('neat.commands.list.headers.aliases').left c3

    puts """
         #{command}#{environment}#{aliases}
         """.yellow, 5

    for k,v of commands
      env = if v.environment? then v.environment.left c2
      else 'default'.left c2

      aliases = if v.aliases? then String(v.aliases).left c3
      else String.fill c3

      puts "#{k.left c1}#{env}#{aliases}", 5

    cb?()

module.exports = {list}
