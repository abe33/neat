{print} = require 'util'

module.exports = (config) ->
  config.engines.logging.console = (logger, log) ->
    print log.message
