module.exports = (config) ->
  config.merge
    verbosity: 0
    engines:
      templates: {}
      databases: {}
      tests: {}
      logging: {}
    tasks: {}
    templatesDirectoryName: 'templates'
    defaultLoggingEngine: 'console'
