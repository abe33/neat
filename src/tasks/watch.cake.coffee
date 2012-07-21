fs = require 'fs'
path = require 'path'
Neat = require '../neat'
{run, neatTask, asyncErrorTrap} = require '../utils/commands'
{error, info, green, red} = require '../utils/logs'

recursiveWatch = (dir, watcher) ->
  fs.readdir dir, asyncErrorTrap (files)->
    files.forEach (file) ->
      file = path.resolve dir, file
      fs.lstat file, asyncErrorTrap (stats) ->
        if stats.isDirectory()
          # Watch the directory and traverse the child file.
          fs.watch file, watcher
          recursiveWatch file, watcher

compiling = false

exports.watch = neatTask
  name:'watch'
  description: 'Watches for changes in the src directory and run compile'
  action: (callback) ->
    recursiveWatch path.resolve('.', 'src'), (e, f) ->
      return if compiling
      compiling = true
      Neat.task('compile') -> compiling = false

    callback?()
