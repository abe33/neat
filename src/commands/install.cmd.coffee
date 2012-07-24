fs = require 'fs'
{resolve} = require 'path'
Neat = require '../neat'

utils = resolve Neat.neatRoot, "lib/utils"

COFFEE = "#{Neat.neatRoot}/node_modules/.bin/coffee"

{puts, error, info, green, red} = require "../utils/logs"
{run, aliases, describe} = require resolve utils, "commands"
{render} = require resolve utils, "templates"

install = (pr) ->
  return error "No program provided to install" unless pr?

  aliases 'i', 'install',
  describe 'Installs all the dependencies listed in the `Nemfile`',
  f = (cb)->
    unless Neat.root?
      return error "Can't run neat install outside of a Neat project."

    fs.readFile 'Nemfile', (err, nemfile) ->
      return error "No #{"Nemfile".red} in the current directory" if err

      puts "Nemfile found"
      render __filename, (err, source) ->
        return error err.message if err?

        source = source.replace "###_NPM_DECLARATION_###", nemfile.toString()

        # The produced source code is then executed by `coffee`.
        run COFFEE, ['-e', source], (status) ->
          if status is 0
            info green "Your bundle is complete."
          else
            error red "An error occured during the installation!"
          cb?()

module.exports = {install}
