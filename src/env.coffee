# This file contains the creation process of the `Neat` object and the
# corresponding environment.

fs = require 'fs'
pr = require 'commander'
{resolve, existsSync:exists} = require 'path'

# We need a reference to the Neat module root directory for later use.
NEAT_ROOT = resolve __dirname, '..'
# `PATHS` will stores the various paths into which Neat will look
# when searching files.
PATHS = [NEAT_ROOT]

# Requiring internal utilities.
utils = "#{NEAT_ROOT}/lib/utils"
{puts, warn, error, missing, neatBroken} = require "#{utils}/logs"
{findSync, neatRootSync, isNeatRootSync} = require "#{utils}/files"
cup = require "#{utils}/cup"

# Paths into which look for configurators and initializers.
envBase = "lib/config/environments"
initBase = "lib/config/initializers"

#### 1. Paths Search

# We look for a Neat project in the current working directory or its ancestors.
userDir = neatRootSync()

#  The current directory can be rattached to a Neat project.
if userDir?
  modulesDir = resolve userDir, "node_modules"
  if exists modulesDir
    # All the node modules that contains a `.neat` file at their
    # root will be appended to `PATHS`.
    modules = fs.readdirSync modulesDir
    modules = (resolve modulesDir, m for m in modules when m isnt "neat")
    PATHS.push m for m in modules when isNeatRootSync m

  else puts warn "No node modules found, run neat install."

  # The current Neat project root is the last path in `PATHS`.
  PATHS.push userDir if userDir not in PATHS

#### 2. Neat Metas

# The `.neat` file at the root of a project contains the metadata
# for the project. In the case of Neat, the `.neat` file is loaded
# and available in `Neat.meta`.
neatFilePath = "#{NEAT_ROOT}/.neat"

try
  neatFile = fs.readFileSync neatFilePath
catch e
  return puts """#{missing neatFilePath}

                 #{neatBroken}"""

meta = cup.read neatFile.toString()
return puts error """Invalid .neat file at:
                     #{neatFilePath.red}

                     #{neatBroken}""" unless meta?

#### 3. Neat Export Definition

# The `Neat` object provides information about Neat and the current project.
Neat =
  meta: meta

  env: {}
  neatRoot: NEAT_ROOT
  paths: PATHS
  root: userDir

  ENV: {}
  NEAT_ROOT: NEAT_ROOT
  PATHS: PATHS
  ROOT: userDir

  #### Environment Setup
  setEnvironment: (env) ->

    # The environment object contains the paths defined in the `Neat` object.
    # In that way, configurators and initializers can perform operations
    # knowing the paths of the project.
    envObject =
      neatRoot: NEAT_ROOT
      paths: PATHS
      root: userDir
      verbose: true

      NEAT_ROOT: NEAT_ROOT
      PATHS: PATHS
      ROOT: userDir

    ##### Configurations

    # The `configurators` array initially contains the files which
    # must be executed before any other configurator.
    #
    # The default configurators are always called to ensure that
    # the environment defaults are present if not overriden
    # by the specified environment.
    paths = @paths.map (p)-> "#{p}/#{envBase}"
    configurators = findSync /^default$/, "js", paths

    return puts error """#{missing 'config/environments/default.js'}

                         #{neatBroken}""" unless configurators? and
                                                 configurators.length isnt 0

    # Configurators for the given environment are searched in the
    # `environments` directory of each path.
    files = findSync ///^#{env}$///, "js", paths
    configurators.push f for f in files when f not in configurators

    # All the configurators found are required and then executed.
    for configurator in configurators
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
        puts error 'Something went wrong with a configurator!!!'.red
        puts e.stack if envObject.verbose
    ##### Initializations

    # Every initializers are executed whatever the environment.
    initializers = findSync 'js', @paths.map (o) -> "#{o}/#{initBase}"

    for initializer in initializers
      # The same precautions are taken towards initializers execution
      # as for configurators.
      try
        {initialize} = require initializer
        initialize? envObject
      catch e
        puts error 'Something went wrong with an initializer!!!'.red
        puts e.stack if envObject.verbose

    # The new environment object is then stored in `Neat`.
    @ENV = @env = envObject

# The `default` environment is loaded at startup, ensuring that all subsequent
# scripts can access elements defined in the configuration.
Neat.setEnvironment "default"

module.exports = {Neat}
