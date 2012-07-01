fs = require 'fs'
{resolve} = require 'path'
Neat = require '../neat'

utils = resolve Neat.neatRoot, "lib/utils"

{findSiblingFile} = require resolve utils, "files"
{puts, error, info, warn, missing, neatBroken} = require resolve utils, "logs"
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
        run 'coffee', ['-e', source], ->
          info "Your bundle is complete.".green
          cb?()

module.exports = {install}
