fs = require 'fs'
path = require 'path'
Q = require 'q'
Neat = require '../neat'
Watcher = require './watch/watcher'
{neatTask} = Neat.require 'utils/commands'

exports['watch:new'] = neatTask
  name: 'watch:new'
  description: 'Attempt to create a smarter watch task'
  environment: 'default'
  action: (callback) -> new Watcher().init()

