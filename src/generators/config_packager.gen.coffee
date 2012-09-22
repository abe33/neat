fs = require 'fs'
Neat = require '../neat'

{describe, usages} = Neat.require 'utils/commands'
{namedEntity} = Neat.require 'utils/generators'
_ = Neat.i18n.getHelper()

usages 'neat generate config:packager <name>',
describe _('neat.commands.generate.config_packager.description'),
generator = namedEntity __filename, 'config/packages', 'cup'

exports['config:packager'] = generator
