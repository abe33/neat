class DoccoTitleProcessor

  @asCommand = (p,c,t) -> (cb) -> new DoccoTitleProcessor(p,c,t).process cb

  constructor: (@path, @section, @titles) ->
    @START_TAG = /<h(\d)>/g
    @END_TAG = /<\/h(\d)>/g

  process: (callback) ->
    @processTag callback

  hasTags: -> @section.docs_html.search(@START_TAG, @cursor) isnt -1

  processTag: (callback) ->
    startMatch = @START_TAG.exec @section.docs_html
    if startMatch?
      level = parseInt startMatch[1]
      endMatch = @END_TAG.exec @section.docs_html

      content = @section.docs_html.substring @START_TAG.lastIndex,
                                             endMatch.index
      id = content.parameterize()

      match = "<h#{level}>#{content}</h#{level}>"
      replacement = "<h#{level} id='#{id}'>#{content}</h#{level}>"
      @section.docs_html = @section.docs_html.replace match, replacement

      @titles.push {id, content, level}

      @START_TAG.lastIndex += id.length + 6
      @END_TAG.lastIndex += id.length + 6
      @processTag callback
    else
      return callback?()

module.exports = DoccoTitleProcessor
