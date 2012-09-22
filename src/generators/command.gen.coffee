fs = require 'fs'
Neat = require '../neat'

{describe, usages} = Neat.require 'utils/commands'
{namedEntity} = Neat.require 'utils/generators'
_ = Neat.i18n.getHelper()

usages 'neat generate command <name> {description, environment, usages}',
describe _('neat.commands.generate.command.description'),
command = namedEntity __filename, 'src/commands', 'cmd.coffee'

module.exports = {command}
