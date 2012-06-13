# TODO: Expose here the elements that should be part of the Neat lib.
{resolve} = require 'path'
{Neat} = require './env'

utils = resolve Neat.neatRoot, 'lib/utils'

# TODO: combine-like method to build
module.exports = {
  Neat
  utils:
    commands:  require resolve utils, 'commands'
    cup:       require resolve utils, 'cup'
    exports:   require resolve utils, 'exports'
    files:     require resolve utils, 'files'
    logs:      require resolve utils, 'logs'
    templates: require resolve utils, 'templates'
}
