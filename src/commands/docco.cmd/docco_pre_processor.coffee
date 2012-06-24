fs = require 'fs'
{resolve} = require 'path'

try
  {parse, highlight} = require 'docco'
catch e
  return puts error """#{'Can\'t find the docco module.'.red}

                       Run cake install to install the dependencies"""

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

    highlight @path, [pre], =>
      match = START_TAG + code + END_TAG
      pre.code_html = pre.code_html.replace '\n</pre>', '</pre>'
      @section.docs_html = @section.docs_html.replace match, pre.code_html

      @cursor = startTagPos + pre.code_html.length
      if @hasTags() then @processTag callback
      else
        callback?()

module.exports = DoccoPreProcessor
