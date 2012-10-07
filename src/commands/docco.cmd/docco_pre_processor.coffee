fs = require 'fs'
Neat = require '../../neat'

{resolve} = require 'path'
{error} = Neat.require 'utils/logs'
_ = Neat.i18n.getHelper()

try
  {parse} = require 'docco'
catch e
  return error _('neat.commands.docco.missing_module',
                  missing: missing 'docco')

try
  {highlight} = require 'highlight.js'
catch e
  return error _('neat.commands.docco.missing_module',
                  missing: missing 'docco')

class DoccoPreProcessor

  START_TAG = '<pre><code>'
  END_TAG = '</code></pre>'

  @asCommand = (p,c) -> (cb) -> new DoccoPreProcessor(p,c).process cb

  constructor: (@path, @section) ->

  process: (callback) ->
    @cursor = 0
    return callback?() unless @hasTags()

    @processTag callback

  hasTags: -> @section.docs_html.indexOf(START_TAG, @cursor) isnt -1

  processTag: (callback) ->
    startTagPos = @section.docs_html.indexOf START_TAG, @cursor
    endTagPos = @section.docs_html.indexOf END_TAG, @cursor

    code = @section.docs_html.substring startTagPos + START_TAG.length,
                                           endTagPos

    pre =
      docs_text: ''
      code_text: code.strip().replace(/&gt;/g, '>').replace(/&lt;/g, '<')

    res = highlight('coffeescript', pre.code_text)
    pre.code_html = res.value

    pre.code_html = "#{START_TAG}#{pre.code_html}#{END_TAG}"
    match = "#{START_TAG}#{code}#{END_TAG}"
    match = "#{START_TAG}#{code}#{END_TAG}"

    @section.docs_html = @section.docs_html.replace match, pre.code_html

    @cursor = startTagPos + pre.code_html.length
    if @hasTags() then @processTag callback
    else
      callback?()

module.exports = DoccoPreProcessor
