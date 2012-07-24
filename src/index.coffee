# This file is the main module that can be loaded inside a Neat project.

# The core classes extensions are required at startup.
require './core/types'

# The `Neat` class instance that provides access to the environment
# is provided under the name `Neat` on the exposed module.
#
#     {Neat} = require 'neat'
Neat = require './neat'

module.exports = Neat
