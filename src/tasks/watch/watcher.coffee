fs = require 'fs'
os = require 'os'
rl = require 'readline'
path = require 'path'
Q = require 'q'
Neat = require '../../neat'
Watch = require './watch'
n = Neat.require 'notifications'
{parallel} = Neat.require 'async'
{compile} = require 'coffee-script'
{
  warn, error, puts, yellow,
  green, red, cyan, inverse
} = Neat.require 'utils/logs'
{asyncErrorTrap} = Neat.require 'utils/commands'

existsSync = fs.existsSync or path.existsSync

class Watcher
  constructor: ->
    switch os.platform()
      when 'darwin'
        @notifier = new n.Notifier new n.plugins.Growly
      when 'linux'
        @notifier = new n.Notifier new n.plugins.NotifySend

    @notifier.notify success: true, title: 'Watchfile', message: 'loaded'

  init: =>
    data = {}
    @watches = {}
    promise = @loadWatchignore()
    .then (ignoreList) =>
      @ignoreList = data.ignoreList = ignoreList
    .then(@indexPaths)
    .then (paths) =>
      {@watchedPaths, @ignoredPaths} = paths
      data = data.merge paths
    .then(@loadWatchfile)
    .then(@evaluateWatchfile)
    .then(@registerWatchers)
    .then ->
      puts green 'Watcher initialized'
      puts yellow "#{data.watchedPaths.length} files watched"
    .then(@initializePlugins)
    .then(@startCLI)
    .then ->
      return data
    .fail (err) ->
      error red err.message
      puts err.stack.join '\n'

    @promise ||= promise

    process.on 'SIGINT', @sigintListener
    process.stdin.on 'keypress', @keypressListener

    promise

  dispose: =>
    promise = Q.fcall =>
      watch.close() for k,watch of @watches
      @watches = null
      @ignoreList = null
      @watchedPaths = null
      @ignoredPaths = null
      @cli.close()
      @cli.removeListener 'line', @lineListener
      @cli.removeListener 'SIGINT', @lineListener
      process.removeListener 'SIGINT', @sigintListener
      process.stdin.removeListener 'keypress', @keypressListener
    promise = promise.then(-> plugin.dispose()) for k,plugin of @plugins
    promise.then => @plugins = null

  isIgnored: (file) ->
    @ignoreList.some (i) -> ///#{Neat.root}/#{i}///.test file

  watcher: (path) =>
    lastTime = 0

    changesSpacedEnough = (time) ->
      result = time - lastTime >= 1000
      lastTime = time
      result

    (action) =>
      time = new Date()
      return unless changesSpacedEnough(time.getTime())

      @pathChanged path, action

  pathChanged: (path, action) ->
    promise = @promise.then =>
      @cliPaused = true
      puts cyan "\r#{inverse " #{action.toUpperCase()}D "} #{path}"
    switch path
      when Neat.resolve('Watchfile'), Neat.resolve('.watchignore')
        promise = promise.then(@dispose).then(@init)
      else
        @plugins.each (name, plugin) =>
          if plugin.match path
            p = plugin.pathChanged path, action
            promise = promise.then =>
              @activePlugin = plugin
              puts cyan "#{inverse " #{name.toUpperCase()} "} #{path}"
            promise = promise.then p

    @promise = promise.then =>
      @cliPaused = false
      @cli.prompt()

  runAll: ->
    promise = @promise.then =>
      @cliPaused = true
      puts cyan "\r#{inverse ' WATCH '} Run all"

    @plugins.each (name, plugin) =>
      promise = promise.then plugin.runAll

    @promise = promise.then =>
      @cliPaused = false
      @cli.prompt()

  enqueue: (promise) ->
    @promise = @promise.then promise

  loadWatchfile: =>
    defer = Q.defer()
    fs.readFile Neat.resolve('Watchfile'), (err, file) ->
      return defer.reject err if err?
      defer.resolve file.toString()

    defer.promise

  initializePlugins: =>
    Q.all(plugin.init(this) for k, plugin of @plugins)

  loadWatchignore: =>
    defer = Q.defer()
    fs.readFile Neat.resolve('.watchignore'), (err, file) ->
      return defer.reject err if err?
      defer.resolve file.toString().split('\n').select (s) -> s.length > 0

    defer.promise

  indexPaths: =>
    defer = Q.defer()
    watchedPaths = []
    ignoredPaths = []
    search = (root) => (cb) =>
      return ignoredPaths.push(root) and cb?() if @isIgnored root

      watchedPaths.push root
      fs.lstat root, (err, stats) ->
        if stats.isDirectory()
          fs.readdir root, (err, paths) ->
            parallel (search(path.resolve root, p) for p in paths), cb
        else
          cb?()

    search(Neat.root) ->
      defer.resolve {watchedPaths, ignoredPaths}
    defer.promise

  watchDirectory: (directory, watcher) =>
    return unless existsSync directory
    @watches[directory] = fs.watch directory, (action) =>
      @enqueue Q.fcall =>
        files = try
          fs.readdirSync directory
        catch err
          []

        for file in files
          file = path.resolve directory, file

          unless file of @watches or @isIgnored file
            # FIXME In some cases, when exiting, an exception
            # is raised here due to an ENOENT error.
            # Currently the exception is silently handled.
            try
              stats = fs.lstatSync file
              if stats.isDirectory()
                @watchDirectory file, watcher
              else
                w = watcher(file)
                w 'create', file
                @rewatch file, w

              @watchedPaths.push file

      , 0

  rewatch: (file, watcher) =>
    if @watches[file]?
      @watches[file].close()

    @watches[file] = fs.watch file, (action) =>
      exist = existsSync file
      action = 'delete' unless exist

      watcher action, file
      if exist
        @rewatch file, watcher
      else
        @watchedPaths

  registerWatchers: =>
    @watchedPaths.forEach (path) =>
      stats = fs.lstatSync path
      if stats.isDirectory()
        @watchDirectory path, @watcher
      else
        @rewatch path, @watcher(path)

  evaluateWatchfile: (watchfile) =>
    @plugins = {}
    currentWatcher = null
    currentGroup = null

    plugins = Neat.require 'watchers'

    watcher = (name, options, block) =>
      [options, block] = [block, options] if typeof options is 'function'
      options ||= {}
      if name of plugins
        @plugins[name] ?= new plugins[name] options, this
        currentWatcher = name
        block.call()
      else
        warn yellow "Unregistered plugin #{name}"

    group = (name, block) =>
      currentGroup = name
      block.call()

    watch = (pattern, options, block) =>
      [options, block] = [block, options] if typeof options is 'function'
      options ||= {}

      re = ///#{Neat.root}/#{pattern}///
      @plugins[currentWatcher].watch new Watch re, options, block

    eval compile watchfile, bare: true

  startCLI: =>
    @cli = rl.createInterface
      input: process.stdin
      output: process.stdout
      # completer: -> console.log arguments
    @cli.setPrompt 'neat: '
    @cli.on 'line', @lineListener
    @cli.on 'SIGINT', @sigintListener
    @cli.prompt()

  toString: -> "[object Watcher]"

  sigintListener: =>
    if @activePlugin?.isPending()
      puts yellow "\n#{@activePlugin} interrupted"
      @activePlugin.kill('SIGINT')
    else
      process.exit(1)

  keypressListener: (s, key) =>
    if key? and key.ctrl and key.name is 'l'
      process.stdout.write '\u001B[2J\u001B[0;0f'
      @cli.prompt() unless @cliPaused

  lineListener: (line) =>
    unless @cliPaused
      switch line
        when '', 'a', 'all' then @runAll()
        when 'q', 'quit', 'e', 'exit' then process.exit(1)
        when 'h', 'help'
          console.log """
          #{cyan '↩, a, all'}: Run all plugins.
          #{cyan 'h, help'}: Print this message.
          #{cyan 'q, quit, e, exit'}: Kill cake watch.
          """
          @cli.prompt()
        else
          puts red "Unknown command '#{line}'"
          @cli.prompt()

module.exports = Watcher
