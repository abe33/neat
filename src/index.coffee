# TODO: Expose here the elements that should be part of the Neat lib.
{resolve} = require 'path'
Neat = require './neat'

module.exports = {
  Neat
  async: require resolve Neat.neatRoot, 'lib/async'
  core: require resolve Neat.neatRoot, 'lib/core'
  utils: require resolve Neat.neatRoot, 'lib/utils'
}
