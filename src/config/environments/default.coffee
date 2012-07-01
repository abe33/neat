module.exports = (config) ->
  config.verbosity = 0

  config.engines =
    templates: {}
    databases: {}
    tests: {}
    logging: {}

  config.defaultLoggingEngine = 'console'

