# This file is the main module that can be loaded inside a Neat project.

## Neat
#
# Neat is a coffeescript project structure combined with a customizable
# command line interface. It can be used both on server side using
# [Node.js](http://nodejs.org/) or to build client side javascript
# libraries with file concatenation and minification.
#
#@toc

#### Installation
#
# Install [Node.js](http://nodejs.org/), and then the
# [Coffeescript](http://jashkenas.github.com/coffee-script) compiler through
# `npm` (having a global installation of Coffeescript is a good practice if you
# plan to work on Neat itself):
#
# ```bash
# npm install -g coffee-script```
#
# Installing Neat through `npm`:
#
# ```bash
# npm install -g neat```
#
# Installing Neat from sources:
#
# ```bash
# git clone git://github.com/abe33/neat.git
# cd neat
# cake install
# cake deploy```

#### A first test


#### The actual index

# The core classes extensions are required at startup.
require './core/types'

# The `Neat` class instance that provides access to the environment
# is provided under the name `Neat` on the exposed module.
#
#     Neat = require 'neat'
Neat = require './neat'

module.exports = Neat
