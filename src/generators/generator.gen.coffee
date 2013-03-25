fs = require 'fs'
Neat = require '../neat'

{describe, usages} = Neat.require 'utils/commands'
{namedEntity} = Neat.require 'utils/generators'
_ = Neat.i18n.getHelper()

usages 'neat generate generator <name>',
describe _('neat.commands.generate.generator.description'),
generator = namedEntity __filename, 'src/generators', 'gen.coffee'

module.exports = {generator}

