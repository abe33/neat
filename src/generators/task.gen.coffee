fs = require 'fs'

{describe, usages} = require '../utils/commands'
{namedEntity} = require '../utils/generators'

usages 'neat generate tasks [name]',
describe 'Generates a [name] task in the tasks directory',
task = namedEntity __filename, 'src/tasks', 'cake.coffee'

module.exports = {task}
