{findSync} = require "../../../utils/files"

exports.initialize = (config) ->

  sources = []
  sources = sources.concat findSync 'coffee', 'src/core'
  sources = sources.concat findSync 'coffee', 'src/utils'

  config.docco =
    paths:
      sources: sources
