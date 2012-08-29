Neat = require '../neat'
{run, neatTask} = require '../utils/commands'
{error, info, green, red} = require '../utils/logs'

exports.compile = neatTask
  name:'compile'
  description: 'Compiles the sources'
  action: (callback) ->
    {coffee, args} = Neat.config.tasks.compile
    Neat.beforeCompilation.dispatch()
    run coffee, args, (status) ->

      if status is 0
        info green 'Compilation done'
      else
        error red 'Compilation failed'

      Neat.afterCompilation.dispatch()
      callback? status
