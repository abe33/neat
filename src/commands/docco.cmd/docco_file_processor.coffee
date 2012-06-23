fs = require 'fs'
{resolve} = require 'path'

{render} = require '../../utils/templates'

DoccoPreProcessor = require './docco_pre_processor'
Parallel = require '../../async/parallel'

try
  {parse, highlight} = require 'docco'
catch e
  return puts error """#{'Can\'t find the docco module.'.red}

                       Run cake install to install the dependencies"""

class DoccoFileProcessor

  @TPL_PATH = resolve __dirname.replace('.cmd',''), '_page'

  @asCommand = (f, h, n) -> (cb) -> new DoccoFileProcessor(f, h, n).process cb

  constructor: (@file, @header, @nav) ->

  highlightFile: (path, sections, callback) ->
    highlight path, sections, =>
      processors = []
      for section in sections
        processors.push DoccoPreProcessor.asCommand path, section

      new Parallel(processors).run ->
        callback()

  process: (callback) ->
    fs.readFile @file.path, (err, code) =>
      throw err if err?

      sections = parse @file.path, code.toString()
      @highlightFile @file.path, sections, =>

        context = {sections, @header, @nav}
        render @constructor.TPL_PATH, context, (err, page) =>
          throw err if err?

          fs.writeFile @file.outputPath, page, (err) =>
            throw err if err?
            console.log "source for #{@file.relativePath}
                         documentation processed".squeeze()
            callback?()

module.exports = DoccoFileProcessor
