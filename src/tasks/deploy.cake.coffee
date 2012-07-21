Neat = require '../neat'
{run, neatTask} = require '../utils/commands'
{error, info, green, red, puts} = require '../utils/logs'

exports.deploy = neatTask
  name:'deploy'
  description: 'Installs the module globally through npm'
  action: (callback) ->
    Neat.task('compile') (status) ->
      if status is 0
        run 'npm', ['install', '-g'], (status) ->
          if status is 0
            info green 'Neat installed'
          else
            error red 'Something went wrong during installation'
          callback? status
      else
        puts 'Compilation have failed, please fix it before
              deploying the module again'.squeeze()
        callback? status
