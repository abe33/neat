Neat = require '../neat'
Builder = Neat.require 'tasks/build/builder'
{neatTask} = Neat.require 'utils/commands'

exports['build'] = neatTask
  name: 'build'
  description: 'Run builds defined in the Neatfile'
  environment: 'default'
  action: (callback) ->
    new Builder().init()
    .then ->
      callback? 0
    .fail ->
      callback? 1

