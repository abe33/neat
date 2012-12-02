fs = require 'fs'
{resolve} = require 'path'
Neat = require '../neat'

{describe, usages} = Neat.require 'utils/commands'
{namedEntity} = Neat.require 'utils/generators'
{render} = Neat.require "utils/templates"
{touch} = Neat.require "utils/files"
_ = Neat.i18n.getHelper()

usages 'neat generate config:packager <name>',
describe _('neat.commands.generate.config_packager.description'),
packagerConfig = namedEntity __filename, 'config/packages', 'cup'

exports['config:packager'] = packagerConfig

usages 'neat generate config:packager:compile',
describe 'Generates the default compilation config for older projects',
exports['config:packager:compile'] = (generator, args..., cb) ->
  unless Neat.root?
    throw new Error notOutsideNeat 'config:packager:compile'
  path = resolve __dirname, 'config_packager/compile'
  render path, (err, result) ->
    touch "#{Neat.root}/config/packages/compile.cup", result, (err) ->
      cb?()


