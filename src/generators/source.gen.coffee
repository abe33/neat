fs = require 'fs'
{resolve} = require 'path'
Neat = require '../neat'

{describe, usages} = Neat.require 'utils/commands'
{multiEntity} = Neat.require 'utils/generators'
{render} = Neat.require "utils/templates"
{touch} = Neat.require "utils/files"
_ = Neat.i18n.getHelper()

entities =
  source:
    dir: 'src'
    ext: '.coffee'
  unit:
    dir: 'test/units'
    ext: '.spec.coffee'
  functional:
    dir: 'test/functionals'
    ext: '.spec.coffee'
  helper:
    dir: 'test/helpers'
    ext: '_helper.coffee'

usages 'neat generate source <name> [options]',
describe _('neat.commands.generate.source.description'),
source = multiEntity __filename, entities

exports['source'] = source
