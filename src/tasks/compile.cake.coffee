Neat = require '../neat'
{run, neatTask} = require '../utils/commands'
{error, info, green, red} = require '../utils/logs'

exports.compile = neatTask
  name:'compile'
  description: 'Compiles the sources'
  action: (callback) ->
    lib = "#{Neat.root}/lib"
    src = "#{Neat.root}/src"
    run 'coffee', ['-c', '-o', lib, src], (status) ->

      if status is 0
        info green 'Compilation done'
      else
        error red 'Compilation failed'

      callback? status
