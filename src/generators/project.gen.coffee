{resolve, existsSync:exists, basename, extname} = require 'path'
Neat = require '../neat'
{puts, error, warn, missing, neatBroken, green} = Neat.require "utils/logs"
{ensureSync, touchSync} = Neat.require "utils/files"
{namespace} = Neat.require "utils/exports"
{renderSync:render} = Neat.require "utils/templates"
{usages, describe, hashArguments} = Neat.require "utils/commands"

usages 'neat generate project <name> {description, author, keywords}',
describe '''Creates a <name> directory with the default neat project content
            Description, author and keywords can be defined using the hash
            arguments.''',
project = (generator, name, args..., callback) ->
  throw new Error "Missing name argument" unless name?

  args.push callback if args.length is 0 and typeof callback isnt 'function'

  path = resolve '.', name
  base = basename __filename
  ext = extname __filename
  tplpath = resolve __dirname, "project"

  context = if args.empty() then {} else hashArguments args
  context.merge {name, version: Neat.meta.version}

  ensureSync path

  dirs = [
    "config",
    "lib",
    "src",
    "src/commands",
    "src/config",
    "src/config/environments",
    "src/config/initializers",
    "src/config/initializers/commands",
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
    ["config/.gitkeep"],
    ["lib/.gitkeep"],
    ["src/commands/.gitkeep"],
    ["src/config/environments/default.coffee", true]
    ["src/config/environments/development.coffee", true]
    ["src/config/environments/production.coffee", true]
    ["src/config/environments/test.coffee", true]
    ["src/config/initializers/commands/docco.coffee", true]
    ["src/generators/.gitkeep"],
    ["src/tasks/.gitkeep"],
    ["templates/.gitkeep"],
    ["test/fixtures/.gitkeep"],
    ["test/functionals/.gitkeep"],
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
    p = resolve(path, a)
    if c
      touchSync p, render resolve(tplpath, b), context
    else
      touchSync p
    puts green("#{p} generated"), 1

  e = (d) ->
    ensureSync resolve path, d
    puts green("#{d} generated"), 1

  try
    e d for d in dirs
    t a,b,c for [a,b,c] in files
  catch e
    e.message = """Cannot proceed to the generation of the project

                   #{e.message}"""
    throw e

    callback?()

module.exports = {project}
