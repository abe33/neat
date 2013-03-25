fs = require 'fs'
{relative, resolve} = require 'path'

Neat = require '../neat'
{describe, usages} = Neat.require 'utils/commands'
{namespace} = Neat.require 'utils/exports'
{namedEntity} = Neat.require 'utils/generators'
_ = Neat.i18n.getHelper()

meta = (name, target) ->
  usages "neat generate spec:#{name} <name>",
  describe _("neat.commands.generate.spec.#{name}.description"),
  target

context = {
  relative
  root: Neat.root
  testPath: resolve Neat.root, 'test'
}

meta 'unit',
unit = namedEntity __filename,
                   'test/units',
                   'spec.coffee',
                   context

meta 'functional',
functional = namedEntity __filename,
                        'test/functionals',
                        'spec.coffee',
                        context

module.exports = namespace 'spec', {unit, functional}
