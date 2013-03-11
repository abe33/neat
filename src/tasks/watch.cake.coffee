fs = require 'fs'
path = require 'path'
Neat = require '../neat'
{run, neatTask, asyncErrorTrap} = Neat.require 'utils/commands'
{error, info, green, red} = Neat.require 'utils/logs'
_ = Neat.i18n.getHelper()

lastTime = 0
changesSpacedEnough = (time) ->
  result = lastTime - time > 0.0000000001
  lastTime = time
  return result

recursiveWatch = (dir, watcher) ->
  fs.watch dir, watcher
  fs.readdir dir, asyncErrorTrap (files)->
    files.forEach (file) ->
      file = path.resolve dir, file
      fs.lstat file, asyncErrorTrap (stats) ->
        if stats.isDirectory()
          # Watch the directory and traverse the children files.
          recursiveWatch file, watcher

compiling = false

exports.watch = neatTask
  name:'watch'
  description: _('neat.tasks.watch.description')
  action: (callback) ->
    recompileAfter = false
    watcher = (e, f) ->
      if compiling and changesSpacedEnough(new Date().getTime())
        recompileAfter = true
        return
      compiling = true
      Neat.task('compile') ->
        compiling = false
        if recompileAfter
          recompileAfter = false
          watcher(e,f)
    recursiveWatch path.resolve('.', 'src'), watcher

exports['watch:test'] = neatTask
  name:'watch:test'
  description: _('neat.tasks.watch_test.description')
  action: (callback) ->
    retestAfter = false
    watcher = (e, f) ->
      if testing and changesSpacedEnough(new Date().getTime())
        retestAfter = true
        return
      testing = true
      Neat.task('test') ->
        testing = false
        if retestAfter
          retestAfter = false
          watcher(e,f)

    recursiveWatch path.resolve('.', 'src'), watcher
    recursiveWatch path.resolve('.', 'test'), watcher

