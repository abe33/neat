# This file is the main module that can be loaded inside a Neat project.
# It contains all the submodules that defines the Neat API.

# The `Neat` class instance that provides access to the environment
# is provided under the name `Neat` on the exposed module.
#
#     {Neat} = require 'neat'
module.exports =
  Neat:  require './neat'
  # Each of the included submodules contains an index file that defines
  # which parts of their content are exposed.
  async: require './async'
  core:  require './core'
  utils: require './utils'
