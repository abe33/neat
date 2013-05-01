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
  #     i18n.get (path.to.string')
  #     i18n.get ('fr', 'path.to.string')
  #
  # If the path lead to a dead end, the function return the last element
  # in the path as a capitalized sentence.
  #
  #     i18n.get (path.that.do_not_exist) # Do Not Exist
  get: (language, path) ->
    [language, path] = [@defaultLanguage, language] unless path?
    lang = @locales[language]

    throw new Error "Language #{language} not found" unless lang?
    els = path.split('.')
    (lang = lang[v]; break unless lang?) for v in els
    lang = els.last().replace(/[-_]/g, ' ').capitalizeAll() unless lang?
    lang

  ##### I18n::getHelper

  # Returns a helper function bound to the current instance that allow
  # to retrieve localized string from the `I18n` instance as well as doing
  # token substitution in the returned string.
  #
  #     _ = i18n.getHelper()
  #     _('path.to.string')
  #     _('path.to.string_with_token', token: 'token substitute')
  getHelper: -> (path, tokens) =>
    @get(path).replace /\#\{([^\}]+)\}/g, (token, key) ->
      return token unless tokens[key]?
      tokens[key]

  ##### I18n::load

  # Search and loads locales files in the given paths, parse their content
  # and fill the `locales` object with the resuts.
  load: ->
    @locales = {}
    docs = readFilesSync findSync 'yml', @paths

    @deepMerge @locales, yaml.load content.toString() for path, content of docs
    @languages = @locales.sortedKeys()

  ##### I18n::deepMerge

  # Merge two tree structures formed by nested objects into one tree structure.
  #
  #     source =
  #       foo:
  #         bar: 10
  #     target =
  #       foo:
  #         baz: 20
  #     deepMerge target, source
  #     # target = {foo: {bar: 10, baz: 20}}
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
