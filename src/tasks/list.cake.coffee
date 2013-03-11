Neat = require '../neat'
{run, neatTask} = Neat.require 'utils/commands'
{error, info, green, red, puts} = Neat.require 'utils/logs'
{first, last, length, property} = Neat.require 'utils/mappers'
_ = Neat.i18n.getHelper()

exports['list'] = neatTask
  name: 'list'
  description: _('neat.tasts.list.description')
  environment: 'production'
  action: (callback) ->
    tasks = Neat.require('tasks')
    t = tasks.flatten().group(2)
    c1 = t.map(first length()).max() + 4
    c2 = t.map(last property 'environment', length()).compact().max() + 4

    task = _('neat.tasks.list.task').left c1
    environment = _('neat.tasks.list.environment').left c2

    puts """
         #{task}#{environment}
         """.yellow, 5

    for k,v of tasks
      env = if v.environment? then v.environment.left c2
      else 'default'.left c2

      puts "#{k.left c1}#{env}", 5

    callback? 0
