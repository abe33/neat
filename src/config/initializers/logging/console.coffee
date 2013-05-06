util = require 'util'

module.exports = (config) ->
  config.engines.logging.console = (logger, log) ->
    util.print log.message if log.level >= config.verbosity
