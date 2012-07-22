path = require 'path'
Neat = require '../neat'
{queue} = require '../async'
{neatTask} = require '../utils/commands'
{error, info, green, red, yellow, puts} = require '../utils/logs'


test = (k,f) -> (callback) ->
  puts yellow "Running tests using #{k.capitalize()}:"
  f ->
    puts ''
    callback?()

exports.test = neatTask
  name:'test'
  description: 'Tests the sources'
  action: (callback) ->
    Neat.task('compile') (status) ->
      if status is 0
        puts ''
        actions = (test k,f for k,f of Neat.env.engines.tests)
        queue actions, ->
          info green 'All tests complete'
          callback?()
      else
        puts
        callback?()
