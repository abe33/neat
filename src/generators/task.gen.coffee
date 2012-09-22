fs = require 'fs'
Neat = require '../neat'

{describe, usages} = Neat.require 'utils/commands'
{namedEntity} = Neat.require 'utils/generators'
_ = Neat.i18n.getHelper()

usages 'neat generate tasks <name> {description, environment}',
describe _('neat.commands.generate.task.description'),
task = namedEntity __filename, 'src/tasks', 'cake.coffee'

module.exports = {task}
