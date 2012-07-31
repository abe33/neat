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

  context = if args.empty() then {} else hashArguments args
  context.merge {name, version: Neat.meta.version}

  ensureSync path

  dirs = [
    "lib",
    "src",
    "src/commands",
    "src/config",
    "src/config/environments",
    "src/config/initializers",
    "src/generators",
    "src/tasks",
    "templates",
    "test",
    "test/fixtures",
    "test/functionals",
    "test/integrations",
    "test/units",
  ]

  files = [
    ["lib/.gitkeep"],
    ["src/commands/.gitkeep"],
    ["src/config/environments/default.coffee", true]
    ["src/config/environments/development.coffee", true]
    ["src/config/environments/production.coffee", true]
    ["src/config/environments/test.coffee", true]
    ["src/config/initializers/docco.coffee", true]
    ["src/generators/.gitkeep"],
    ["src/tasks/.gitkeep"],
    ["templates/.gitkeep"],
    ["test/fixtures/.gitkeep"],
    ["test/functionals/.gitkeep"],
    ["test/integrations/.gitkeep"],
    ["test/test_helper.coffee", true]
    ["test/units/.gitkeep"],
    ['.gitignore', true],
    ['.neat', true],
    ['.npmignore', true],
    ['Cakefile', true],
    ['Nemfile', true],
  ]

  t = (a, b, c=false) ->
    [b,c] = [a,b] if typeof b is 'boolean'
    b = a unless b?
    if c
      touchSync resolve(path, a), render resolve(tplpath, b), context
    else
      touchSync resolve(path, a)

  e = (d) -> ensureSync resolve path, d

  try
    e d for d in dirs
    t a,b,c for [a,b,c] in files
  catch e
    return error """Cannot proceed to the generation of the project

                 #{e.stack}"""

  callback?()

module.exports = {project}
