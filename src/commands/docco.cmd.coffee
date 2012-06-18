fs = require 'fs'
{resolve, existsSync, basename, extname, relative} = require 'path'
{Neat} = require '../neat'

utils = resolve Neat.neatRoot, 'lib/utils'

{puts, error, warn, missing, neatBroken} = require resolve utils, 'logs'
{aliases, describe} = require resolve utils, 'commands'
{ensureSync} = require resolve utils, 'files'
{render} = require resolve utils, 'templates'

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

class DoccoFile
  constructor: (@path) ->
    @relativePath = relative Neat.root, @path
    @basename = basename @path
    outputBase = @relativePath.replace(extname(@path), '').underscore()
    @outputPath = "#{Neat.root}/docs/#{outputBase}.html"
    @linkPath = relative "#{Neat.root}/docs", @outputPath

docco = (pr) ->
  return puts error 'No program provided to docco' unless pr?

  aliases 'docco',
  describe 'Generates the documentation for a Neat project through docco',
  f = (callback) ->
    unless Neat.root?
      return puts error "Can't run neat docco outside of a Neat project."

    try
      {parse, highlight} = require 'docco'
    catch e
      return puts error """#{'Can\'t find the docco module.'.red}

                           Run cake install to install the dependencies"""

    paths = Neat.env.docco.paths.sources.concat()
    if not paths? or paths.empty()
      return puts warn 'No paths specified for documentation generation.'

    navTplPath = resolve __dirname, 'docco/_navigation'
    headerTplPath = resolve __dirname, 'docco/_header'
    pageTplPath = resolve __dirname, 'docco/_page'

    files = (new DoccoFile path for path in paths)

    ensureSync resolve Neat.root, 'docs'

    render navTplPath, {files}, (err, nav) ->
      throw err if err?

      render headerTplPath, {files}, (err, header) ->
        throw err if err?

        generateDocumentation = (file, sources, callback) ->
          fs.readFile file.path, (err, code) ->
            throw err if err?
            sections = parse file.path, code.toString()
            highlight file.path, sections, ->
              context = {sections, header, nav}
              render pageTplPath, context, (err, page) ->
                throw err if err?
                fs.writeFile file.outputPath, page, (err) ->
                  throw err if err?
                  console.log "source for #{file.relativePath}
                               documentation processed".squeeze()
                  callback?()

        nextFile =  ->
          if files.length
            generateDocumentation files.shift(),
                                  Neat.env.docco.paths.sources,
                                  nextFile
          else
            console.log 'Documentation successfully generated'.green
            callback?()

        nextFile()

module.exports = {docco}
