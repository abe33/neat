fs = require 'fs'

{describe, usages} = require '../utils/commands'
{namedEntity} = require '../utils/generators'

usages 'neat generate config:packager <name>',
describe 'Generates a <name> packager config in the config/packages directory',
generator = namedEntity __filename, 'src/config/packages', 'cup'

exports['config:packager'] = generator
