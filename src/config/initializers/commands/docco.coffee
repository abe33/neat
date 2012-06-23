{findSync} = require "../../../utils/files"

exports.initialize = (config) ->

  dirs = [
    'src/async',
    'src/core',
    'src/utils',
  ]

  sources = [
    'src/neat.coffee',
    'src/env.coffee',
    'src/index.coffee',
  ]
  sources = sources.concat findSync 'coffee', d for d in dirs

  config.docco =
    paths:
      sources: sources

