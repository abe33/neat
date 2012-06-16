{resolve, existsSync} = require 'path'
{Neat} = require '../neat'

utils = resolve Neat.neatRoot, "lib/utils"

{findSync} = require resolve utils, "files"
{puts, error, warn, missing, neatBroken} = require resolve utils, "logs"
{run, aliases, describe} = require resolve utils, "commands"

# TODO: Fork docco and exports the program to use it directly here
docco = (pr) ->
  return puts error "No program provided to docco" unless pr?

  aliases 'docco',
  describe 'Generates the documentation for a Neat project through docco',
  f = (callback) ->
    unless Neat.root?
      return puts error "Can't run neat docco outside of a Neat project."

    doccoPath = resolve Neat.neatRoot, 'node_modules/.bin/docco'
    unless existsSync doccoPath
      return puts error "Docco module not found, run neat install."

    files = findSync 'coffee', resolve Neat.root, 'src/core'
    # files = files.concat resolve Neat.root, 'Cakefile'
    files.sort()

    return puts warn "No source files in the current project" unless files?

    run doccoPath, files, callback

module.exports = {docco}
