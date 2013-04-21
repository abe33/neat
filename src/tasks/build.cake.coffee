Neat = require '../neat'
Builder = Neat.require 'tasks/build/builder'
{neatTask} = Neat.require 'utils/commands'

exports['build'] = neatTask
  name: 'build'
  description: 'Attempt to create a promise-based build task'
  environment: 'default'
  action: (callback) -> new Builder().init().then callback

