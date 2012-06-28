module.exports = (config) ->
  config.verbose = false

  config.engines =
    templates: {}
    databases: {}
    tests: {}
    logging: {}

  config.defaultLoggingEngine = 'console'

