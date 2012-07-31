fs = require 'fs'

{describe, usages} = require '../utils/commands'
{namespace} = require '../utils/exports'
{namedEntity} = require '../utils/generators'

meta = (name, target) ->
  usages "neat generate spec:#{name} [name]",
  describe "Generates a [name] spec in the test/#{name}s directory",
  target

meta 'unit',
unit = namedEntity __filename, 'test/units', 'spec.coffee'

meta 'functional',
functional = namedEntity __filename, 'test/functionals', 'spec.coffee'

meta 'integration',
integration = namedEntity __filename, 'test/integrations', 'spec.coffee'

module.exports = namespace 'spec', {unit, functional, integration}
