fs = require 'fs'
{resolve, existsSync, basename, extname, relative} = require 'path'
Neat = require '../../neat'

{error, info, warn, missing, green} = Neat.require 'utils/logs'
{aliases, describe, environment} = Neat.require 'utils/commands'
{ensureSync} = Neat.require 'utils/files'
{render} = Neat.require 'utils/templates'
{namespace} = Neat.require 'utils/exports'
{parallel} = Neat.require 'async'

DoccoFile = require './docco_file'
Processor = require './docco_file_processor'

hashify = (files) ->
  filesHash = {}
  deepestLevel = 0
  for file in files
    path = file.relativePath.split '/'
    end = path.pop()
    o = filesHash[path.shift()] ||= {}
    level = 1

    while path.length
      p = path.shift()
      level += 1
      o = o[p] ||= {}

    o[end] = file
    level += 1
    deepestLevel = Math.max deepestLevel, level

  [filesHash, deepestLevel]

cmdgen = (name, desc, fn) -> (pr) ->
  return error "No program provided to #{name}" unless pr?

  aliases name,
  describe desc,
  environment 'production',
  f = (callback) ->
    unless Neat.root?
      return error "Can't run neat #{name} outside of a Neat project."

    ensureSync resolve Neat.root, 'docs'
    fn pr, callback

name = 'docco:javascript'
desc = 'Generates the documentation javascript'
javascript = cmdgen name, desc, (pr, callback) ->
  dirname = __dirname.replace '.cmd', ''
  jsTplPath = resolve dirname, '_javascript'
  render jsTplPath, {}, (err, js) ->
    throw err if err?
    fs.writeFile "#{Neat.root}/docs/docco.js", js, (err) ->
      throw err if err?
      info green 'Javascript successfully generated'
      callback?()

name = 'docco:stylesheet'
desc = 'Generates the documentation stylesheet'
stylesheet = cmdgen name, desc, (pr, callback) ->
  render __dirname, (err, css) ->
    throw err if err?
    fs.writeFile "#{Neat.root}/docs/docco.css", css, (err) ->
      throw err if err?
      info green 'Stylesheet successfully generated'
      callback?()

name = 'docco:documentation'
desc = 'Generates the documentation throug docco'
documentation = cmdgen name, desc, (pr, callback) ->
  paths = Neat.config.docco.paths.sources.concat()
  if not paths? or paths.empty()
    return warn 'No paths specified for documentation generation.'

  dirname = __dirname.replace '.cmd', ''
  navTplPath = resolve dirname, '_navigation'
  headerTplPath = resolve dirname, '_header'
  pageTplPath = resolve dirname, '_page'

  files = (new DoccoFile path for path in paths)

  [filesHash, deepestLevel] = hashify files

  context = {files, filesHash, deepestLevel}

  render navTplPath, context, (err, nav) ->
    throw err if err?
    render headerTplPath, context, (err, header) ->
      throw err if err?
      processors = []
      for file in files
        processors.push Processor.asCommand(file, header, nav)

      parallel processors, ->
        info green 'Documentation successfully generated'
        callback?()

name = 'docco'
desc = 'Generates the documentation for a Neat project through docco'

index = cmdgen name, desc, (pr, cb) ->
  javascript(pr) -> stylesheet(pr) -> documentation(pr) cb

module.exports = namespace 'docco', {
  index
  javascript
  stylesheet
  documentation
}
