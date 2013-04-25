{resolve, basename, extname} = require 'path'
Neat = require '../neat'
{puts, error, warn, missing, green} = Neat.require "utils/logs"
{ensureSync, touchSync} = Neat.require "utils/files"
{namespace} = Neat.require "utils/exports"
{renderSync:render} = Neat.require "utils/templates"
{usages, describe, hashArguments} = Neat.require "utils/commands"
_ = Neat.i18n.getHelper()

usages 'neat generate project <name> {description, author, keywords}',
describe _('neat.commands.generate.project.description'),
project = (generator, name, args..., callback) ->
  throw new Error _('neat.errors.missing_argument', {name}) unless name?

  args.push callback if args.length is 0 and typeof callback isnt 'function'

  path = resolve '.', name
  base = basename __filename
  ext = extname __filename
  tplpath = resolve __dirname, 'project'

  context = if args.empty() then {} else hashArguments args
  context.merge {name, version: Neat.meta.version}

  ensureSync path

  dirs = [
    'lib',
    'src',
    'src/commands',
    'src/config',
    'src/config/environments',
    'src/config/initializers',
    'src/generators',
    'src/tasks',
    'templates',
    'test',
    'test/fixtures',
    'test/helpers',
    'test/functionals',
    'test/integrations',
    'test/units',
  ]

  files = [
    ['lib/.gitkeep'],
    ['src/commands/.gitkeep'],
    ['src/config/environments/default.coffee', true]
    ['src/config/environments/development.coffee', true]
    ['src/config/environments/production.coffee', true]
    ['src/config/environments/test.coffee', true]
    ['src/config/initializers/.gitkeep']
    ['src/generators/.gitkeep'],
    ['src/tasks/.gitkeep'],
    ['templates/.gitkeep'],
    ['test/fixtures/.gitkeep'],
    ['test/helpers/.gitkeep'],
    ['test/functionals/.gitkeep'],
    ['test/integrations/.gitkeep'],
    ['test/test_helper.coffee', true]
    ['test/units/.gitkeep'],
    ['.gitignore', true],
    ['.neat', true],
    ['.npmignore', true],
    ['Cakefile', true],
    ['Nemfile', true],
    ['Neatfile', true],
    ['Watchfile', true],
  ]

  t = (a, b, c=false) ->
    [b,c] = [a,b] if typeof b is 'boolean'
    b = a unless b?
    p = resolve(path, a)
    if c
      touchSync p, render resolve(tplpath, b), context
    else
      touchSync p
    puts green(_('neat.commands.generate.project.generation_done', path: p)), 1

  e = (d) ->
    p = resolve path, d
    ensureSync p
    puts green(_('neat.commands.generate.project.generation_done', path: p)), 1

  try
    e d for d in dirs
    t a,b,c for [a,b,c] in files
  catch e
    e.message = _('neat.commands.generate.project.generation_failed',
                   message: e.message)
    throw e

  callback?()

module.exports = {project}
