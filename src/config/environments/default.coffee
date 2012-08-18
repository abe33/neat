module.exports = (config) ->
  config.merge
    verbosity: 0
    engines:
      templates: {}
      databases: {}
      tests: {}
      logging: {}

    tasks:
      compile:
        sourceDirectory: 'src'
        compilationDirectory: 'lib'

    defaultLoggingEngine: 'console'
