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
        coffee: "#{config.neatRoot}/node_modules/.bin/coffee"
        args: ['-c', '-o', "#{config.root}/lib", "#{config.root}/src"]

    defaultLoggingEngine: 'console'
