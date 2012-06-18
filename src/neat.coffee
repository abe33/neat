# This file contains the creation process of the `Neat` object and the
# corresponding environment.

fs = require 'fs'
pr = require 'commander'
{resolve, existsSync:exists} = require 'path'

# We need a reference to the Neat module root directory for later use.
NEAT_ROOT = resolve __dirname, '..'

# Requiring internal utilities.
utils = "#{NEAT_ROOT}/lib/utils"
{puts, warn, error, missing, neatBroken} = require "#{utils}/logs"
{findSync, neatRootSync, isNeatRootSync} = require "#{utils}/files"
cup = require "#{utils}/cup"

# The `Neat` object provides information about Neat and the current project.
class Neat
  #### Environment Setup
  constructor: (root) ->
    @root     = @ROOT      = root
    @neatRoot = @NEAT_ROOT = NEAT_ROOT
    # Paths where environments and initializers can be found.
    @envPath  = @ENV_PATH  = 'lib/config/environments'
    @initPath = @INIT_PATH = 'lib/config/initializers'
    # `PATHS` will stores the various paths into which Neat will look
    # when searching files.
    @paths    = @PATHS     = [@neatRoot]
    # The environment object is defined asynchronously through
    # the `initEnvironment` or the `setEnvironment` methods.
    @env      = @ENV       = null
    @meta     = @META      = @loadMeta()

    @discoverUserPaths() if @root?

  # Browses the user directory to find neat projects either at the
  # root directory or in the node modules installed in the project.
  discoverUserPaths: ->
    modulesDir = resolve @root, 'node_modules'
    if exists modulesDir
      # All the node modules that contains a `.neat` file at their
      # root will be appended to `PATHS`.
      modules = fs.readdirSync modulesDir
      modules = (resolve modulesDir, m for m in modules when m isnt 'neat')
      @paths.push m for m in modules when isNeatRootSync m

    else puts warn 'No node modules found, run neat install.'

    # The current Neat project root is the last path in `PATHS`.
    @paths.push @root if @root not in @paths

  # Loads and returns the meta contained in the `.neat` file.
  loadMeta: ->
    # The `.neat` file at the root of a project contains the metadata
    # for the project. In the case of Neat, the `.neat` file is loaded
    # and available in `Neat.meta`.
    neatFilePath = "#{@neatRoot}/.neat"

    try
      neatFile = fs.readFileSync neatFilePath
    catch e
      return puts """#{missing neatFilePath}

                     #{neatBroken}"""

    meta = cup.read neatFile.toString()
    meta or puts error """Invalid .neat file at:
                          #{neatFilePath.red}

                          #{neatBroken}"""

  # Initializes the `Neat` instance with the default environment.
  # If the `NEAT_ENV` environment variable is set, the corresponding
  # environment is loaded.
  initEnvironment: ->
    @setEnvironment process.env['NEAT_ENV'] or 'default'

  # Changes the environment of the `Neat` instance. All the process
  # of loading the environment configurators and the initializers
  # are executed on a brand new environment object.
  setEnvironment: (env) ->
    # The environment object contains the paths defined in the `Neat` object.
    # In that way, configurators and initializers can perform operations
    # knowing the paths of the project.
    envObject = {
      @root, @neatRoot, @paths, @initPath, @envPath,
      @ROOT, @NEAT_ROOT, @PATHS, @INIT_PATH, @ENV_PATH,
      verbose:false,
    }

    ##### Configurations

    # The `configurators` array initially contains the files which
    # must be executed before any other configurator.
    #
    # The default configurators are always called to ensure that
    # the environment defaults are present if not overriden
    # by the specified environment.
    paths = @paths.map (p)=> "#{p}/#{@envPath}"
    configurators = findSync /^default$/, 'js', paths

    return puts error """#{missing 'config/environments/default.js'}

                         #{neatBroken}""" unless configurators? and
                                                 configurators.length isnt 0

    # Configurators for the given environment are searched in the
    # `environments` directory of each path.
    files = findSync ///^#{env}$///, "js", paths
    configurators.push f for f in files when f not in configurators

    # All the configurators found are required and then executed.
    for configurator in configurators
      puts "Running #{configurator}" if envObject.verbose
      # The execution of a configurator is handled in a `try..catch` block
      # in order to avoid a failing configurators to prevent `Neat`
      # to be loaded.
      # For instance this behavior is needed to run `neat install` in a fresh
      # project where some dependencies cannot be satisfied yet because
      # no modules have been installed.
      try
        {setup} = require configurator
        setup? envObject
      catch e
        # However errors are reported to the console.
        puts error """#{'Something went wrong with a configurator!!!'.red}

                      #{e.stack}"""
    ##### Initializations

    # Every initializers are executed whatever the environment.
    initializers = findSync 'js', @paths.map (o) => "#{o}/#{@initPath}"

    for initializer in initializers
      # The same precautions are taken towards initializers execution
      # as for configurators.
      try
        {initialize} = require initializer
        initialize? envObject
      catch e
        puts error """#{'Something went wrong with an initializer!!!'.red}

                      #{e.stack}"""

    # The new environment object is then stored in `Neat`.
    @ENV = @env = envObject

module.exports = Neat: new Neat neatRootSync()
