{findSync} = require "../../../utils/files"

module.exports = (config) ->

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
  sources = sources.concat findSync('coffee', d)?.sort() for d in dirs

  config.docco =
    paths:
      sources: sources.compact()
