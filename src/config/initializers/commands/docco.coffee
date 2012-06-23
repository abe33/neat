{findSync} = require "../../../utils/files"

exports.initialize = (config) ->

  # sources = ['/home/cedric/Developpement/javascript/coffeescript/neat/src/core/types/string.coffee']
  sources = []
  sources = sources.concat findSync 'coffee', 'src/core'
  sources = sources.concat findSync 'coffee', 'src/utils'

  config.docco =
    paths:
      sources: sources

