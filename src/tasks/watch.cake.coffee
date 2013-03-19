fs = require 'fs'
path = require 'path'
Neat = require '../neat'
{run, neatTask, asyncErrorTrap} = Neat.require 'utils/commands'
{error, puts, info, green, red, cyan} = Neat.require 'utils/logs'
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

watchTaskGen = (name, task, description, watches...) ->
  watches = watches.flatten()
  rerunAfter = false
  exports[name] = neatTask
    name: name
    description: description
    action: (callback) ->
      rerunAfter = false
      watcher = (e, f) ->
        if testing and changesSpacedEnough(new Date().getTime())
          rerunAfter = true
          return
        puts cyan "#{f or '<file name not provided>'} #{e}d"
        testing = true
        # Neat.task(task) ->
        run 'cake', [task], (status) ->
          testing = false
          if rerunAfter
            rerunAfter = false
            watcher(e,f)

      recursiveWatch path.resolve('.', w), watcher for w in watches

      if watches.length is 1
        info green _('neat.tasks.watch.watching_singular', dir: watches)
      else
        info green _('neat.tasks.watch.watching_plural', dirs: watches)

watchTaskGen 'watch', 'compile', _('neat.tasks.watch.description'), 'src'
watchTaskGen 'watch:test', 'test',
             _('neat.tasks.watch_test.description'),
             'src', 'test/units', 'test/functionals'
watchTaskGen 'watch:test:unit', 'test:unit',
             _('neat.tasks.watch_test_unit.description'),
             'src', 'test/units'
watchTaskGen 'watch:test:functional', 'test:functional',
             _('neat.tasks.watch_test_functional.description'),
             'src', 'test/functionals'
watchTaskGen 'watch:test:integration', 'test:integration',
             _('neat.tasks.watch_test_integration.description'),
             'src', 'test/integrations'

