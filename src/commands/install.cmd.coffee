fs = require 'fs'
{resolve} = require 'path'
Neat = require '../neat'

COFFEE = "#{Neat.neatRoot}/node_modules/.bin/coffee"
{puts, error, info, green, red; notOutsideNeat} = Neat.require "utils/logs"
{run, aliases, describe, environment} = Neat.require "utils/commands"
{'package.json':generate} = Neat.require 'generators'
{render} = Neat.require "utils/templates"
_ = Neat.i18n.getHelper()

install = (pr) ->
  unless pr?
    throw new Error _('neat.commands.no_program', command:'install')

  aliases 'i', 'install',
  environment 'all',
  describe _('neat.commands.install.description'),
  f = (args..., callback)->
    unless Neat.root?
      throw new Error notOutsideNeat 'neat install'

    fs.readFile 'Nemfile', (err, nemfile) ->
      throw new Error _('neat.errors.no_nemfile') if err

      puts "Nemfile found"
      render __filename, (err, source) ->
        throw err if err?

        source = source.replace "###_NPM_DECLARATION_###", nemfile.toString()
        source = source.replace "###_ENV_###", "env = '#{Neat.env}'"

        # The produced source code is then executed by `coffee`.
        run COFFEE, ['-e', source], (status) ->
          if status is 0
            info green _('neat.commands.install.install_done')
          else
            error red _('neat.commands.install.install_failed')

          generate 'package.json', ->
            callback?()

module.exports = {install}
