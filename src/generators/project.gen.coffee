{resolve, existsSync:exists, basename, extname} = require 'path'
Neat = require '../neat'
{puts, error, warn, missing, neatBroken} = require resolve Neat.neatRoot,
                                                           "lib/utils/logs"
{ensureSync, touchSync} = require resolve Neat.neatRoot, "lib/utils/files"
{namespace} = require resolve Neat.neatRoot, "lib/utils/exports"
{renderSync:render} = require resolve Neat.neatRoot, "lib/utils/templates"
{usages, describe} = require resolve Neat.neatRoot, "lib/utils/commands"

usages 'neat generate project [name]',
describe 'Creates a [name] directory with the default neat project content',
project = (generator, name, args..., callback) ->
  return error "Missing name argument" unless name?

  path = resolve '.', name
  base = basename __filename
  ext = extname __filename
  tplpath = resolve __dirname, "project"

  gitignore = resolve path, ".gitignore"
  npmignore = resolve path, ".npmignore"
  neatfile  = resolve path, ".neat"
  nemfile   = resolve path, "Nemfile"
  cakefile  = resolve path, "Cakefile"

  ensureSync path

  try
    touchSync gitignore, render resolve(tplpath, ".gitignore")
    touchSync npmignore, render resolve(tplpath, ".npmignore")
    touchSync neatfile,  render resolve(tplpath, ".neat"), name: name
    touchSync nemfile,   render resolve(tplpath, "Nemfile")
    touchSync cakefile,  render resolve(tplpath, "Cakefile")

    ensureSync resolve path, "lib"
    ensureSync resolve path, "src"
    ensureSync resolve path, "src/commands"
    ensureSync resolve path, "src/generators"
    ensureSync resolve path, "src/tasks"
    ensureSync resolve path, "src/config"
    ensureSync resolve path, "src/config/environments"
    ensureSync resolve path, "src/config/initializers"
    ensureSync resolve path, "templates"
    ensureSync resolve path, "test"
    ensureSync resolve path, "test/fixtures"
    ensureSync resolve path, "test/spec"

    touchSync resolve path, "lib/.gitkeep"
    touchSync resolve path, "src/commands/.gitkeep"
    touchSync resolve path, "src/generators/.gitkeep"
    touchSync resolve path, "src/tasks/.gitkeep"
    touchSync resolve path, "src/config/environments/.gitkeep"
    touchSync resolve path, "src/config/initializers/.gitkeep"
    touchSync resolve path, "templates/.gitkeep"
    touchSync resolve path, "test/.gitkeep"
    touchSync resolve path, "test/fixtures/.gitkeep"
    touchSync resolve path, "test/spec/.gitkeep"
  catch e
    return error """Cannot proceed to the generation of the project

                 #{e.stack}"""

  callback?()

module.exports = {project}
