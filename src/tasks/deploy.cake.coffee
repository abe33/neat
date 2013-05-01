Neat = require '../neat'
{run, neatTask} = Neat.require 'utils/commands'
{error, info, green, red, puts, warn} = Neat.require 'utils/logs'
_ = Neat.i18n.getHelper()

exports.deploy = neatTask
  name:'deploy'
  description: _('neat.tasks.deploy.description')
  action: (callback) ->
    Neat.task('compile') (status) ->
      if status is 0
        run 'npm', ['install', '-g'], (status) ->
          if status is 0
            info green _('neat.tasks.deploy.deploy_done')
          else
            error red _('neat.tasks.deploy.deploy_failed')
          callback? status
      else
        warn _('neat.tasks.deploy.compile_failed')
        callback? status
