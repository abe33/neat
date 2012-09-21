# This file contains the class that manage the loading, parsing and retrieving
# of the localized strings.
#@toc
yaml = require 'js-yaml'
{findSync, readFilesSync} = require '../utils/files'

## I18n

# The `I18n` class is a small utility that search for `yml` files
# in the given paths and gather the results in a single `locales`
# object.
class I18n
  ##### I18n::constructor

  # The paths into which looking for files are provided in the constructor.
  #
  #     i18n = new I18n Neat.paths.map (p) -> "#{p}/src/config/locales"
  constructor: (@paths=[], @defaultLanguage='en') ->

  ##### I18n::get

  # Returns a string from the locales.
  # That function can be called either with or without a language:
  #
  #     i18n
  get: (language, path) ->
    [language, path] = [@defaultLanguage, language] unless path?
    lang = @locales[language]

    throw new Error "Language #{language} not found" unless lang?
    els = path.split('.')
    (lang = lang[v]; break unless lang?) for v in els
    lang = els.last().replace(/[-_]/g, ' ').capitalizeAll() unless lang?
    lang

  getHelper: -> (path, tokens) =>
    @get(path).replace /\#\{([^\}]+)\}/g, (token, key) -> tokens[key] or token

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
