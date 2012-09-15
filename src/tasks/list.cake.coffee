Neat = require 'neat'
{run, neatTask} = Neat.require 'utils/commands'
{error, info, green, red, puts} = Neat.require 'utils/logs'
{first, last, length, property} = Neat.require 'utils/mappers'

exports['list'] = neatTask
  name: 'list'
  description: 'List all the tasks and provides details about them'
  environment: 'production'
  action: (callback) ->
    tasks = Neat.require('tasks')
    t = tasks.flatten().group(2)
    c1 = t.map(first length()).max() + 4
    c2 = t.map(last property 'environment', length()).compact().max() + 4

    puts """
         #{'Task'.left c1}#{'Environment'.left c2}
         """.yellow, 5

    for k,v of tasks
      env = if v.environment? then v.environment.left c2
      else 'default'.left c2

      puts "#{k.left c1}#{env}", 5

    callback?()
