Neat = require '../neat'
{run, neatTask} = Neat.require 'utils/commands'
{error, info, green, red, puts} = Neat.require 'utils/logs'
_ = Neat.i18n.getHelper()

exports['version'] = neatTask
  name:'version'
  description: _('neat.tasks.version.description')
  environment: 'production'
  action: (callback) ->
    info _('neat.tasks.version.message', {
      name: Neat.project.name,
      version: green Neat.project.version
    })
    callback? 0
