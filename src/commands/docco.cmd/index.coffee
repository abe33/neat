fs = require 'fs'
{resolve, existsSync, basename, extname, relative} = require 'path'
Neat = require '../../neat'

utils = resolve Neat.neatRoot, 'lib/utils'

{puts, error, warn, missing, neatBroken} = require resolve utils, 'logs'
{aliases, describe} = require resolve utils, 'commands'
{ensureSync} = require resolve utils, 'files'
{render} = require resolve utils, 'templates'
Parallel = require '../../async/parallel'

DoccoFile = require './docco_file'
Processor = require './docco_file_processor'

# The following expression math sprockets like require
# in documentation and extract the token to require.
#
# In fact, the token is the base name of a configuration
# file in `config/commands/docco/demos` that will be used to generate
# a live demo within the documentation.
REQUIRE_RE = ///^
  \s*           # indentation
  \#=\s*require # rails convention for require
  \s+
  ([^\s]+)      # the configuration name
///gm

docco = (pr) ->
  return puts error 'No program provided to docco' unless pr?

  aliases 'docco',
  describe 'Generates the documentation for a Neat project through docco',
  f = (callback) ->
    unless Neat.root?
      return puts error "Can't run neat docco outside of a Neat project."

    paths = Neat.env.docco.paths.sources.concat()
    if not paths? or paths.empty()
      return puts warn 'No paths specified for documentation generation.'

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
          console.log 'Documentation successfully generated'.green
          callback?()

module.exports = {docco}
