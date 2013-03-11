fs = require 'fs'
{resolve, relative} = require 'path'
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
    partial: '../spec.gen.coffee'
  functional:
    dir: 'test/functionals'
    ext: '.spec.coffee'
    partial: '../spec.gen.coffee'
  helper:
    dir: 'test/helpers'
    ext: '_helper.coffee'
    partial: 'helper'

context = {
  relative
  root: Neat.root
  testPath: resolve(Neat.root, 'test')
  hasSource: true
}

usages 'neat generate source <name> [options] {helper, functional, unit}',
describe _('neat.commands.generate.source.description'),
source = multiEntity __filename, entities, context

exports['source'] = source
