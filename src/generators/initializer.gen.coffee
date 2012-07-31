fs = require 'fs'

{describe, usages} = require '../utils/commands'
{namedEntity} = require '../utils/generators'

usages 'neat generate initializer <name>',
describe 'Generates a <name> initializer in the config/initializers directory',
initializer = namedEntity __filename, 'src/config/initializers', 'coffee'

module.exports = {initializer}
