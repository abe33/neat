fs = require 'fs'
path = require 'path'
Q = require 'q'
Neat = require '../neat'
{compile} = require 'coffee-script'
{run, neatTask, asyncErrorTrap} = Neat.require 'utils/commands'
{error, info, green, red, yellow, cyan, puts} = Neat.require 'utils/logs'
{parallel} = Neat.require 'async'

existsSync = fs.existsSync or path.existsSync

WATCHERS = Neat.require 'watchers'
ALL_FILES = null
IGNORE_LIST = null
ACTIONS_MAP = {}
WATCHES = {}

isIgnored = (file) ->
  IGNORE_LIST.some (i) -> ///#{Neat.root}/#{i}///.test file

watchDirectory = (directory, watcher) ->
  fs.watch directory, (action) ->
    setTimeout ->
      files = fs.readdirSync directory
      for file in files
        file = path.resolve directory, file

        unless file in ALL_FILES or isIgnored file
          stats = fs.lstatSync file
          if stats.isDirectory()
            watchDirectory file, watcher
          else
            w = watcher(file)
            w 'create', file
            rewatch file, w

          ALL_FILES.push file
    , 0

rewatch = (file, watcher) ->
  if WATCHES[file]?
    WATCHES[file].close()

  WATCHES[file] = fs.watch file, (action) ->
    exist = existsSync file
    action = 'delete' unless exist

    watcher action, file
    if exist
      rewatch file, watcher
    else
      ALL_FILES

recursiveWatch = (dir, watcher) ->
  return if isIgnored dir
  watchDirectory dir, watcher
  fs.readdir dir, asyncErrorTrap (files)->
    files.forEach (file) ->
      file = path.resolve dir, file
      return if isIgnored file
      fs.lstat file, asyncErrorTrap (stats) ->
        if stats.isDirectory()
          # Watch the directory and traverse the children files.
          recursiveWatch file, watcher
          watchDirectory file, watcher
        else
          # Watch the file
          rewatch file, watcher(file)

indexFiles = (callback) ->
  allFiles = []
  search = (root) -> (cb) ->
    return cb?() if isIgnored root

    allFiles.push root
    fs.lstat root, (err, stats) ->
      if stats.isDirectory()
        fs.readdir root, (err, paths) ->
          parallel (search(path.resolve root, p) for p in paths), cb
      else
        cb?()

  search(Neat.root) -> callback allFiles

n = 0

promise = null
watcher = (file) ->
  id = n
  n += 1
  lastTime = 0
  rerunAfter = false

  changesSpacedEnough = (time) ->
    result = time - lastTime >= 1000
    lastTime = time
    return result

  (action) ->
    time = new Date()
    return unless changesSpacedEnough(time.getTime())

    puts cyan "#{id.toString().right 4} - #{time} - #{file} #{action}d"
    ACTIONS_MAP.each (watcher, watches) ->
      for [pattern, re, options, block] in watches
        if match = re.exec file
          p = WATCHERS[watcher].call null, match, options, block

          if promise?
            promise = promise.then p
          else
            promise = p()

    promise.fail((err) -> error red err)

exports['watch:new'] = neatTask
  name: 'watch:new'
  description: 'Attempt to create a smarter watch task'
  environment: 'default'
  action: (callback) ->

    fs.readFile "#{Neat.root}/.watchignore", asyncErrorTrap (ignore) ->
      IGNORE_LIST = ignore.toString().split('\n').select (s) -> s.length > 0

      indexFiles (files) ->
        ALL_FILES = files

        fs.readFile "#{Neat.root}/Watchfile", asyncErrorTrap (file) ->

          recursiveWatch Neat.root, watcher
          puts yellow "#{ALL_FILES.length} files found in the project"
          file = file.toString()

          currentWatcher = null
          currentGroup = null

          watcher = (name, block) ->
            ACTIONS_MAP[name] ||= []
            currentWatcher = name
            block.call()

          group = (name, block) ->
            currentGroup = name
            block.call()

          watch = (pattern, options, block) ->
            [options, block] = [block, options] if typeof options is 'function'
            options ||= {}

            re = ///#{Neat.root}/#{pattern}///
            ACTIONS_MAP[currentWatcher].push [
              pattern
              re
              options
              block
            ]

          eval compile file, bare: true
