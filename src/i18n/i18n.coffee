
yaml = require 'js-yaml'
Neat = require '../neat'
{findSync, readFilesSync} = Neat.require 'utils/files'

class I18n
  constructor: (@paths) ->

  get: (language, path) ->
    [language, path] = ['en', language] unless path?
    lang = @locales[language]

    throw new Error "Language #{language} not found" unless lang?
    els = path.split('.')
    lang = lang[v] for v in els
    lang = els.last().replace(/[-_]/g, ' ').capitalizeAll() unless lang?
    lang

  load: ->
    @locales = {}

    docs = readFilesSync findSync 'yml', @paths

    @deepMerge @locales, yaml.load content for path, content of docs
    @languages = @locales.sortedKeys()

  deepMerge: (target, source) ->
    for k,v of source
      switch typeof v
        when 'object'
          if Array.isArray v
            target[k] ||= []
            target[k] = target[k].concat v
          else
            target[k] ||= {}
            @deepMerge target[k], v
        else target[k] = v

module.exports = I18n
