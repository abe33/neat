Neat = require '../neat'
{run, neatTask} = Neat.require 'utils/commands'
{error, info, green, red, puts} = Neat.require 'utils/logs'

exports['version'] = neatTask
  name:'version'
  description: 'Print the project version'
  environment: 'production'
  action: (callback) ->
    info "#{Neat.project.name} version: #{green Neat.project.version}"
    callback?()
