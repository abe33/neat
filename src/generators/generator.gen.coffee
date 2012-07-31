fs = require 'fs'

{describe, usages} = require '../utils/commands'
{namedEntity} = require '../utils/generators'

usages 'neat generate generator <name>',
describe 'Generates a <name> generator in the generators directory',
generator = namedEntity __filename, 'src/generators', 'gen.coffee'

module.exports = {generator}

