fs = require 'fs'
{resolve} = require 'path'
Neat = require '../../neat'
DoccoFile = require './docco_file'
Processor = require './docco_file_processor'

{error, info, warn, missing, green} = Neat.require 'utils/logs'
{aliases, describe, environment} = Neat.require 'utils/commands'
{ensureSync} = Neat.require 'utils/files'
{render} = Neat.require 'utils/templates'
{namespace} = Neat.require 'utils/exports'
{parallel} = Neat.require 'async'
_ = Neat.i18n.getHelper()

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
  unless pr?
    throw new Error _('neat.commands.no_program', command: name)

  aliases name,
  describe desc,
  environment 'production',
  f = (callback) ->
    unless Neat.root?
      throw new Error _("neat.errors.outside_neat", expression: "neat #{name}")

    ensureSync resolve Neat.root, 'docs'
    fn pr, callback

name = 'docco:javascript'
desc = _('neat.commands.docco.javascript_description')
javascript = cmdgen name, desc, (pr, callback) ->
  dirname = __dirname.replace '.cmd', ''
  jsTplPath = resolve dirname, '_javascript'
  render jsTplPath, {}, (err, js) ->
    throw err if err?
    fs.writeFile "#{Neat.root}/docs/docco.js", js, (err) ->
      throw err if err?
      info green _('neat.commands.docco.javascript_generated')
      callback?()

name = 'docco:stylesheet'
desc = _('neat.commands.docco.stylesheet_description')
stylesheet = cmdgen name, desc, (pr, callback) ->
  render __dirname, (err, css) ->
    throw err if err?
    fs.writeFile "#{Neat.root}/docs/docco.css", css, (err) ->
      throw err if err?
      info green _('neat.commands.docco.stylesheet_generated')
      callback?()

name = 'docco:documentation'
desc = _('neat.commands.docco.description')
documentation = cmdgen name, desc, (pr, callback) ->
  paths = Neat.config.docco.paths.sources.concat()
  if not paths? or paths.empty()
    return warn _('neat.commands.docco.no_path')

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
        info green _('neat.commands.docco.documentation_generated')
        callback?()

name = 'docco'
desc = _('neat.commands.docco.description')

index = cmdgen name, desc, (pr, cb) ->
  javascript(pr) -> stylesheet(pr) -> documentation(pr) cb

module.exports = namespace 'docco', {
  index
  javascript
  stylesheet
  documentation
}
