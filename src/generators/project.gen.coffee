{resolve, existsSync:exists, basename, extname} = require 'path'
Neat = require '../neat'
{puts, error, warn, missing, neatBroken} = Neat.require "utils/logs"
{ensureSync, touchSync} = Neat.require "utils/files"
{namespace} = Neat.require "utils/exports"
{renderSync:render} = Neat.require "utils/templates"
{usages, describe, hashArguments} = Neat.require "utils/commands"

usages 'neat generate project <name> {description, author, keywords}',
describe '''Creates a <name> directory with the default neat project content
            Description, author and keywords can be defined using the hash
            arguments.''',
project = (generator, name, args..., callback) ->
  return error "Missing name argument" unless name?
  args.push callback if args.length is 0 and typeof callback isnt 'function'

  path = resolve '.', name
  base = basename __filename
  ext = extname __filename
  tplpath = resolve __dirname, "project"

  gitignore = resolve path, ".gitignore"
  npmignore = resolve path, ".npmignore"
  neatfile  = resolve path, ".neat"
  nemfile   = resolve path, "Nemfile"
  cakefile  = resolve path, "Cakefile"

  context = if args.empty() then {} else hashArguments args
  context.merge {name, version: Neat.meta.version}

  ensureSync path

  try
    touchSync gitignore, render resolve(tplpath, ".gitignore"), context
    touchSync npmignore, render resolve(tplpath, ".npmignore"), context
    touchSync neatfile,  render resolve(tplpath, ".neat"), context
    touchSync nemfile,   render resolve(tplpath, "Nemfile"), context
    touchSync cakefile,  render resolve(tplpath, "Cakefile"), context

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
    ensureSync resolve path, "test/units"
    ensureSync resolve path, "test/functionals"
    ensureSync resolve path, "test/integrations"

    touchSync resolve path, "lib/.gitkeep"
    touchSync resolve path, "src/commands/.gitkeep"
    touchSync resolve path, "src/generators/.gitkeep"
    touchSync resolve path, "src/tasks/.gitkeep"
    touchSync resolve path, "src/config/environments/.gitkeep"
    touchSync resolve path, "templates/.gitkeep"
    touchSync resolve path, "test/fixtures/.gitkeep"
    touchSync resolve path, "test/units/.gitkeep"
    touchSync resolve path, "test/functionals/.gitkeep"
    touchSync resolve path, "test/integrations/.gitkeep"

    touchSync resolve(path, "src/config/initializers/docco.coffee"),
              render resolve(tplpath, "src/config/initializers/docco"), context

    touchSync resolve(path, "test/test_helper.coffee"),
              render resolve(tplpath, "test/test_helper"), context

  catch e
    return error """Cannot proceed to the generation of the project

                 #{e.stack}"""

  callback?()

module.exports = {project}
