Neat = require '../neat'
{run, neatTask} = require '../utils/commands'
{error, info, green, red} = require '../utils/logs'

COFFEE = "#{Neat.neatRoot}/node_modules/.bin/coffee"

exports.compile = neatTask
  name:'compile'
  description: 'Compiles the sources'
  action: (callback) ->
    lib = "#{Neat.root}/#{Neat.config.tasks.compile.compilationDirectory}"
    src = "#{Neat.root}/#{Neat.config.tasks.compile.sourceDirectory}"
    run COFFEE, ['-c', '-o', lib, src], (status) ->

      if status is 0
        info green 'Compilation done'
      else
        error red 'Compilation failed'

      callback? status
