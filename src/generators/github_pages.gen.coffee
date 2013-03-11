{resolve, basename, extname} = require 'path'

Neat = require '../neat'
{describe, usages, hashArguments} = Neat.require 'utils/commands'
{renderSync:render} = Neat.require 'utils/templates'
{ensureSync, touchSync} = Neat.require 'utils/files'
{puts, error, green, red, notOutsideNeat} = Neat.require 'utils/logs'
_ = Neat.i18n.getHelper()

usages 'neat generate github:pages',
describe _('neat.commands.generate.github_pages.description'),
exports['github:pages'] = (generator, args..., callback) ->
  throw new Error notOutsideNeat process.argv.join ' ' unless Neat.root?

  path = resolve '.'
  base = basename __filename
  ext = extname __filename
  tplpath = resolve __dirname, 'github_pages'

  context = if args.empty() then {} else hashArguments args
  context.merge {version: Neat.meta.version}

  dirs = [
    'config',
    'pages',
  ]

  files = [
    ['config/pages.cup', true],
    ['pages/index.md', true],
    ['pages/pages.stylus', true],
  ]

  t = (a, b, c=false) ->
    [b,c] = [a,b] if typeof b is 'boolean'
    b = a unless b?
    p = resolve(path, a)
    if c
      touchSync p, render resolve(tplpath, b), context
    else
      touchSync p
    puts green(_('neat.commands.generate.github_pages.generation_done',
                 path: p)), 1

  e = (d) ->
    p = resolve path, d
    ensureSync p
    puts green(_('neat.commands.generate.github_pages.generation_done',
                 path: p)), 1

  try
    e d for d in dirs
    t a,b,c for [a,b,c] in files
  catch e
    e.message = _('neat.commands.generate.github_pages.generation_failed',
                   message: e.message)
    throw e

  callback?()
