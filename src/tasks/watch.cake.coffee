fs = require 'fs'
path = require 'path'
Neat = require '../neat'
{run, neatTask, asyncErrorTrap} = Neat.require 'utils/commands'
{error, info, green, red} = Neat.require 'utils/logs'
_ = Neat.i18n.getHelper()

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
  description: _('neat.tasks.watch.description')
  action: (callback) ->
    recompileAfter = false
    watcher = (e, f) ->
      if compiling
        recompileAfter = true
        return
      compiling = true
      Neat.task('compile') ->
        compiling = false
        watcher(e,f) if recompileAfter
    recursiveWatch path.resolve('.', 'src'), watcher
