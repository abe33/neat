path = require 'path'
Neat = require '../neat'
{queue} = require '../async'
{neatTask} = require '../utils/commands'
{error, info, green, red, yellow,puts} = require '../utils/logs'

exports.test = neatTask
  name:'test'
  description: 'Tests the sources'
  action: (callback) ->
    Neat.task('compile') (status) ->
      if status is 0
        actions = (f for k,f of Neat.env.engines.tests)
        queue actions, -> callback?()
      else
        puts
        callback?()
