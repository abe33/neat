fs = require 'fs'

{describe, usages} = require '../utils/commands'
{namedEntity} = require '../utils/generators'

usages 'neat generate command [name]',
describe 'Generates a [name] command in the commands directory',
command = namedEntity __filename, 'commands', 'cmd.coffee'

module.exports = {command}
