{findSync} = require "../../../utils/files"

exports.initialize = (config) ->

  dirs = [
    'src/async',
    'src/core',
    'src/utils',
  ]

  sources = []
  sources = sources.concat findSync 'coffee', d for d in dirs

  config.docco =
    paths:
      sources: sources

