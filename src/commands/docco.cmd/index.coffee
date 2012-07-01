fs = require 'fs'
{resolve, existsSync, basename, extname, relative} = require 'path'
Neat = require '../../neat'

utils = resolve Neat.neatRoot, 'lib/utils'

{error, info, warn, missing, neatBroken} = require resolve utils, 'logs'
{aliases, describe} = require resolve utils, 'commands'
{ensureSync} = require resolve utils, 'files'
{render} = require resolve utils, 'templates'
Parallel = require '../../async/parallel'

DoccoFile = require './docco_file'
Processor = require './docco_file_processor'

docco = (pr) ->
  return error 'No program provided to docco' unless pr?

  aliases 'docco',
  describe 'Generates the documentation for a Neat project through docco',
  f = (callback) ->
    unless Neat.root?
      return error "Can't run neat docco outside of a Neat project."

    paths = Neat.env.docco.paths.sources.concat()
    if not paths? or paths.empty()
      return warn 'No paths specified for documentation generation.'

    dirname = __dirname.replace '.cmd', ''
    navTplPath = resolve dirname, '_navigation'
    headerTplPath = resolve dirname, '_header'
    pageTplPath = resolve dirname, '_page'

    files = (new DoccoFile path for path in paths)

    ensureSync resolve Neat.root, 'docs'

    render navTplPath, {files}, (err, nav) ->
      throw err if err?

      render headerTplPath, {files}, (err, header) ->
        throw err if err?

        processors = []
        for file in files
          processors.push Processor.asCommand(file, header, nav)

        new Parallel(processors).run ->
          info 'Documentation successfully generated'.green
          callback?()

module.exports = {docco}
