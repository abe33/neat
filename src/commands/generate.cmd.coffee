{resolve} = require 'path'
{help:helpCmd} = require './help.cmd'
Neat = require '../neat'

{renderSync:render} = Neat.require "utils/templates"
{puts, error, warn, missing} = Neat.require "utils/logs"
{deprecated} = Neat.require "utils/lib"
{
  run, aliases, usages, describe, help, environment
} = Neat.require "utils/commands"
_ = Neat.i18n.getHelper()

generate = (pr, commands) ->
  unless pr?
    throw new Error _('neat.commands.no_program', command: 'generate')

  generators = Neat.require "generators"

  listContext =
    list: generators.map (k,v) ->
      if v.usages?
        [usage, v] for usage in v.usages
      else
        [k,v]
    title: _('neat.commands.generate.help_list_title')

  helpFunc = (target) -> (generator) ->
    helptpl = resolve __dirname, "help"
    if generator? and typeof generator is 'string'
      gen = generators[generator]
      if gen?
        if gen.help? and typeof gen.help is 'function'
          gen.help.apply(null, arguments)
        else
          console.log render helptpl, gen
      else
        throw new Error missing _('neat.commands.generate.generator.name',
                                  {generator})
    else
      context = {}
      context.merge target
      context.help = render resolve(__dirname, "help/_list"), listContext
      console.log render helptpl, context

  aliases 'g', 'generate',
  environment 'production',
  usages 'neat generate [generator]',
  describe _('neat.commands.generate.description'),
  f = (generator, args..., command, callback) ->
    # No generator displays the command help.
    return f.help.apply(null, arguments) and
           callback?() if typeof generator is "object"

    # When no callback is provided to the generator the arguments
    # are reorganized.
    if args.length is 0
      if typeof command isnt "object"
        args.push command
    else if typeof callback isnt "function"
      args.push(command) and command = callback

    unless generator of generators
      return callback?(
        new Error missing _('neat.commands.generate.generator.name',
                            {generator})
      )

    gen = generators[generator]

    deprecated gen.deprecated if gen?.deprecated?

    unless typeof gen is "function"
      return callback? new Error _('neat.commands.generate.invalid_generator',
                                   type: typeof gen)

    gen.apply null, [generator].concat(args).concat(callback)

  help helpFunc(f), f

module.exports = {generate}
