# This file contains the creation process of the `Neat` object and the
# corresponding environment.
# @toc

#
fs = require 'fs'
pr = require 'commander'
path = require 'path'
resolve = path.resolve

existsSync = fs.existsSync or path.existsSync

# We need a reference to the Neat module root directory for later use.
NEAT_ROOT = resolve __dirname, '..'

# Requiring internal utilities.
{logger, puts, warn, error, missing, neatBroken} = require "./utils/logs"
{findSync, neatRootSync, isNeatRootSync} = require "./utils/files"
cup = require "./utils/cup"
require "./core"
Signal = require "./core/signal"
{I18n} = require "./i18n"

## Neat

# A `Neat` instance provides information about Neat and the current project.
class Neat
  ##### Neat::constructor
  constructor: (@ROOT) ->
    ###### Other Constructor Setup
    @defaultEnvironment = 'default'
    @root     = @ROOT
    @neatRoot = @NEAT_ROOT = NEAT_ROOT
    # Paths where environments and initializers can be found.
    @envPath  = @ENV_PATH  = 'lib/config/environments'
    @initPath = @INIT_PATH = 'lib/config/initializers'
    # `PATHS` will stores the various paths into which Neat will look
    # when searching files.
    @paths = @PATHS = [@neatRoot]
    # The config object is defined asynchronously through
    # the `initEnvironment` or the `setEnvironment` methods.
    @config = @config = null
    @env = @ENV = null

    @discoverUserPaths() if @root?

    @initI18n()
    @initHooks()

    # The `.neat` file at the root of a project contains the metadata
    # for the project. In the case of Neat, the `.neat` file is loaded
    # and available in `Neat.meta`.
    @meta = @META = @loadMeta @neatRoot

    # The current project meta are available through `Neat.project`
    # or `Neat.PROJECT`.
    @project = @PROJECT = @loadMeta @root if @root?


  ##### Neat::initHooks

  # Initialize the hooks provided by Neat.
  initHooks: ->

    # The `beforeCommand` and `afterCommand` hooks are triggered
    # respectively before and after the execution of a cli command.
    @beforeCommand = new Signal
    @afterCommand = new Signal

    # The `beforeCompilation` and `afterCompilation` hooks are triggered
    # respectively before and after the compilation task.
    # The listeners to these signals can safely use asynchronous
    # process, the compilation task will proceed accordingly.
    @beforeCompilation = new Signal
    @afterCompilation = new Signal

    # The `beforeTask` and `afterTask` hooks are triggered
    # respectively before and after the execution of a cake task.
    @beforeTask = new Signal
    @afterTask = new Signal

    # The `beforeEnvironment` and `afterEnvironment` hooks are triggered
    # respectively before and after the construction of the environment.
    @beforeEnvironment = new Signal
    @afterEnvironment = new Signal

    # The `beforeInitialize` and `afterInitialize` hooks are triggered
    # respectively before and after the execution of initializers.
    @beforeInitialize = new Signal
    @afterInitialize = new Signal

  ##### Neat::initI18n

  # Initialize the internationalization for the current Neat instance.
  initI18n: ->
    @i18n = new I18n @paths.map (s) -> "#{s}/config/locales"
    @i18n.load()
    puts "Available languages: #{@i18n.languages.join ', '}"

  ##### Neat::require

  # Loads a module from the Neat directory using the `require` function.
  #
  #     Neat = require 'neat'
  #     {parallel} = Neat.require 'async'
  require: (module) -> require "#{@neatRoot}/lib/#{module}"

  ##### Neat::resolve

  resolve: (path) -> resolve @neatRoot, path

  ##### Neat::rootResolve

  rootResolve: (path) -> resolve @root, path

  ##### Neat::task

  # Returns the cake task whose name is `name`.
  #
  #     compile = Neat.task 'compile'
  #     compile (status) ->
  #       # do something after compilation
  task: (name) -> @require('tasks')[name]

  #### Environment Setup

  ##### Neat::initLogging

  # Setup the logging engine for this `Neat` instance.
  initLogging: ->
    logger.add @config.engines.logging[@config.defaultLoggingEngine]

  ##### Neat::initEnvironment

  # Initializes the `Neat` instance with the default environment.
  # If the `NEAT_ENV` environment variable is set, the corresponding
  # environment is loaded.
  initEnvironment: (callback) ->
    @setEnvironment process.env['NEAT_ENV'] or @defaultEnvironment, =>
      @initLogging()
      callback?()

  ##### Neat::setEnvironment

  # Changes the environment of the `Neat` instance. All the process
  # of loading the environment configurators and the initializers
  # are executed on a brand new environment object.
  setEnvironment: (env, callback) ->
    # The environment object contains the paths defined in the `Neat` object.
    # In that way, configurators and initializers can perform operations
    # knowing the paths of the project.
    envObject = {
      @root, @neatRoot,  @paths, @initPath,  @envPath,
      @ROOT, @NEAT_ROOT, @PATHS, @INIT_PATH, @ENV_PATH,
    }

    @beforeEnvironment.dispatch this, envObject, =>

      ###### Configurations
      #
      # Configuration of the environment is done through `configurators`.
      #
      # A configurator is a function exposed as a module and that have
      # the following form:
      #
      #     module.exports = (config) ->
      #       # Setup your configuration here
      #
      # The `config` object contains the environment object which will
      # be available through `Neat.config`.
      #
      # The name of the file is the name of the environment to configure.
      #
      # The default configurators are always called to ensure that
      # the environment defaults are present if not overriden
      # by the specified environment.

      # The `configurators` array initially contains the files which
      # must be executed before any other configurator.
      paths = @paths.map (p)=> "#{p}/#{@envPath}"
      configurators = findSync /^default$/, 'js', paths

      unless configurators? and configurators.length isnt 0
        return error """#{@i18n.getHelper()('neat.errors.missing',
                          missing: 'config/environments/default.js')}

                        #{@i18n.get('neat.errors.broken')}"""

      # Configurators for the given environment are searched in the
      # `environments` directory of each path.
      files = findSync ///^#{env}$///, "js", paths
      configurators.push f for f in files when f not in configurators

      # All the configurators found are required and then executed.
      for configurator in configurators
        puts "Running #{configurator}"
        # The execution of a configurator is handled in a `try..catch` block
        # in order to avoid a failing configurators to prevent `Neat`
        # to be loaded.
        # For instance this behavior is needed to run `neat install` in a fresh
        # project where some dependencies cannot be satisfied yet because
        # no modules have been installed.
        try
          setup = require configurator
          setup? envObject
        catch e
          # However errors are reported to the console.
          error """#{@i18n.get('neat.errors.broken_environment').red}

                   #{e.stack}"""

      @afterEnvironment.dispatch this, envObject, =>
        @beforeInitialize.dispatch this, envObject, =>

          ###### Initializations
          #
          # Initializations of plugins or components are done through
          # `initializers`.
          #
          # An initializer is basically a configurator that will be run after
          # the environment configuration.
          #
          #     module.exports = (config) ->
          #       # Setup for your module here
          #
          # Its purpose is to setup the configuration of a module, a command,
          # or anything else that will run on top of Neat. The sole difference
          # is that an initializer file can't have any name, it will be loaded
          # anyway.

          # Every initializers are executed whatever the environment.
          initializers = findSync 'js', @paths.map (o) => "#{o}/#{@initPath}"

          for initializer in initializers
            # The same precautions are taken towards initializers execution
            # as for configurators.
            try
              initialize = require initializer
              initialize? envObject
            catch e
              error """#{@i18n.get('neat.errors.broken_initializer').red}

                       #{e.stack}"""

          # After configurators and initializers have been run,
          # the new environment object is then stored in `Neat`.
          @CONFIG = @config = envObject
          o = {}
          o[env] = true
          @ENV = @env = Object::merge.call env, o

          @afterInitialize.dispatch this, envObject, callback

  #### Environment Setup Utilities

  ##### Neat::discoverUserPaths

  # Browses the user directory to find neat projects either at the
  # root directory or in the node modules installed in the project.
  discoverUserPaths: ->
    modulesDir = resolve @root, 'node_modules'
    if existsSync modulesDir
      # All the node modules that contains a `.neat` file at their
      # root will be appended to `PATHS`.
      modules = fs.readdirSync modulesDir
      modules = (resolve modulesDir, m for m in modules when m isnt 'neat')
      @paths.push m for m in modules when isNeatRootSync m

    else warn 'No node modules found, run neat install.'

    # The current Neat project root is the last path in `PATHS`.
    @paths.push @root if @root not in @paths

  ##### Neat::loadMeta

  # Loads and returns the meta contained in the `.neat` file.
  loadMeta: (root) ->
    neatFilePath = "#{root}/.neat"

    _ = @i18n.getHelper()

    try
      neatFile = fs.readFileSync neatFilePath
    catch e
      return error """#{_('neat.errors.missing', missing: neatFilePath.red)}

                      #{_('neat.errors.broken')}"""

    meta = cup.read neatFile.toString()

    meta or error """#{_('neat.errors.invalid_neat', path: neatFilePath.red)}

                     #{_('neat.errors.broken')}"""

module.exports = new Neat neatRootSync()
