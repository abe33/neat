fs = require 'fs'

{describe, usages} = require '../utils/commands'
{namedEntity} = require '../utils/generators'

usages 'neat generate command <name> {description, environment, usages}',
describe '''Generates a <name> command in the commands directory.
            Description, usages and environment can be defined with
            the hash arguments syntax.''',
command = namedEntity __filename, 'src/commands', 'cmd.coffee'

module.exports = {command}
