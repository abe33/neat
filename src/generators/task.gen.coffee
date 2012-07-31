fs = require 'fs'

{describe, usages} = require '../utils/commands'
{namedEntity} = require '../utils/generators'

usages 'neat generate tasks <name> {description, environment}',
describe '''Generates a <name> task in the tasks directory.
            Description and environment of the task can be defined
            using hash arguments.''',
task = namedEntity __filename, 'src/tasks', 'cake.coffee'

module.exports = {task}
