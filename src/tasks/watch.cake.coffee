fs = require 'fs'
path = require 'path'
Q = require 'q'
Neat = require '../neat'
Watcher = require './watch/watcher'
{neatTask} = Neat.require 'utils/commands'

exports['watch'] = neatTask
  name: 'watch'
  description: 'Run watchers defined in the Watchfile'
  environment: 'default'
  action: (callback) -> new Watcher().init()

