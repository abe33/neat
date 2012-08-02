{resolve} = require 'path'
{help:helpCmd} = require './help.cmd'
Neat = require '../neat'

utils = resolve Neat.neatRoot, "lib/utils"

{puts, error, warn, missing} = require resolve utils, "logs"
{
  run, aliases, usages, describe, help, environment
} = require resolve utils, "commands"
{renderSync:render} = require resolve utils, "templates"

generate = (pr, commands) ->
  return error "No program provided to generate" unless pr?

  generators = require resolve Neat.neatRoot, "lib/generators"

  listContext =
    list: generators.map (k,v) ->
      if v.usages?
        [usage, v] for usage in v.usages
      else
        [k,v]
    title: "Generators:"

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
        error missing "Generator #{generator}"
    else
      context = {}
      context.merge target
      context.help = render resolve(__dirname, "help/_list"), listContext
      console.log render helptpl, context

  aliases 'g', 'generate',
  environment 'production',
  usages 'neat generate [generator]',
  describe 'Runs the specified [generator]',
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
      return callback? new Error missing "Generator #{generator}"
      callback?()

    gen = generators[generator]

    unless typeof gen is "function"
      return callback? new Error "Generators must be a function,
                                  was #{typeof gen}".squeeze()

    gen.apply null, [generator].concat(args).concat(callback)

  help helpFunc(f), f

module.exports = {generate}
