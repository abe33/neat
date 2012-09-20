fs = require 'fs'
{resolve} = require 'path'
Neat = require '../neat'

COFFEE = "#{Neat.neatRoot}/node_modules/.bin/coffee"
{puts, error, info, green, red} = Neat.require "utils/logs"
{run, aliases, describe} = Neat.require "utils/commands"
{'package.json':generate} = Neat.require 'generators'
{render} = Neat.require "utils/templates"

install = (pr) ->
  throw new Error "No program provided to install" unless pr?

  aliases 'i', 'install',
  describe 'Installs all the dependencies listed in the `Nemfile`',
  f = (args..., callback)->
    unless Neat.root?
      throw new Error "Can't run neat install outside of a Neat project."

    fs.readFile 'Nemfile', (err, nemfile) ->
      throw new Error "No #{"Nemfile".red} in the current directory" if err

      puts "Nemfile found"
      render __filename, (err, source) ->
        throw err if err?

        source = source.replace "###_NPM_DECLARATION_###", nemfile.toString()

        # The produced source code is then executed by `coffee`.
        run COFFEE, ['-e', source], (status) ->
          if status is 0
            info green "Your bundle is complete."
          else
            error red "An error occured during the installation!"

          generate 'package.json', ->
            callback?()

module.exports = {install}
