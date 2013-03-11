fs = require 'fs'
Neat = require '../neat'

{describe, usages} = Neat.require 'utils/commands'
{namedEntity} = Neat.require 'utils/generators'
_ = Neat.i18n.getHelper()

usages 'neat generate initializer <name>',
describe _('neat.commands.generate.initializer.description'),
initializer = namedEntity __filename, 'src/config/initializers', 'coffee'

module.exports = {initializer}
