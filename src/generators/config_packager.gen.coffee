fs = require 'fs'
{resolve} = require 'path'
Neat = require '../neat'

{describe, usages, deprecated} = Neat.require 'utils/commands'
{namedEntity} = Neat.require 'utils/generators'
{render} = Neat.require "utils/templates"
{touch, ensurePath} = Neat.require "utils/files"
{notOutsideNeat} = Neat.require "utils/logs"

_ = Neat.i18n.getHelper()

deprecated 'The old packager based compilation will no longer
be supported in future version of Neat. Use a Neatfile and The
cake build task instead.'.squeeze(),
usages 'neat generate config:packager <name>',
describe _('neat.commands.generate.config_packager.description'),
packagerConfig = namedEntity __filename, 'config/packages', 'cup'

exports['config:packager'] = packagerConfig

deprecated 'The old packager based compilation will no longer
be supported in future version of Neat. Use a Neatfile and The
cake build task instead.'.squeeze(),
usages 'neat generate config:packager:compile',
describe 'Generates the default compilation config for older projects',
exports['config:packager:compile'] = (generator, args..., cb) ->
  throw new Error notOutsideNeat 'config:packager:compile' unless Neat.root?
  path = resolve __dirname, 'config_packager/compile'
  render path, (err, result) ->
    return cb? err if err?
    ensurePath "#{Neat.root}/config/packages/compile.cup", (err) ->
      return cb? err if err?
      touch "#{Neat.root}/config/packages/compile.cup", result, (err) ->
        return cb? err if err?
        cb?()


