fs = require 'fs'
{resolve} = require 'path'

{render} = require '../../utils/templates'

DoccoPreProcessor = require './docco_pre_processor'
DoccoTitleProcessor = require './docco_title_processor'
Parallel = require '../../async/parallel'

try
  {parse, highlight} = require 'docco'
catch e
  return puts error """#{'Can\'t find the docco module.'.red}

                       Run cake install to install the dependencies"""

class DoccoFileProcessor

  TPL_PATH = resolve __dirname.replace('.cmd',''), '_page'
  TPL_TOC = resolve __dirname.replace('.cmd',''), '_toc'

  @asCommand = (f, h, n) -> (cb) -> new DoccoFileProcessor(f, h, n).process cb

  constructor: (@file, @header, @nav) ->

  highlightFile: (path, sections, callback) ->
    highlight path, sections, =>

      titles = []
      presCmd = []
      titlesCmd = []
      for section in sections
        presCmd.push DoccoPreProcessor.asCommand path, section
        titlesCmd.push DoccoTitleProcessor.asCommand path, section, titles

      new Parallel(presCmd).run =>
        new Parallel(titlesCmd).run =>
          minLevel = titles.reduce ((a,b) -> Math.min a, b.level), 100

          render TPL_TOC, {titles, minLevel}, (err, toc) =>
            throw err if err?
            callback toc

  process: (callback) ->
    fs.readFile @file.path, (err, code) =>
      throw err if err?

      sections = parse @file.path, code.toString()
      @highlightFile @file.path, sections, (toc) =>

        context = {sections, @header, @nav, @file}
        render TPL_PATH, context, (err, page) =>
          throw err if err?

          page = page.replace /@toc/g, toc

          fs.writeFile @file.outputPath, page, (err) =>
            throw err if err?
            console.log "source for #{@file.relativePath}
                         documentation processed".squeeze()
            callback?()

module.exports = DoccoFileProcessor
