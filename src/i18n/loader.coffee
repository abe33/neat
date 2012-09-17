
yaml = require 'js-yaml'
Neat = require '../neat'
{find, readFiles} = Neat.require 'utils/files'
{asyncErrorTrap} = Neat.require 'utils/commands'

class Loader
  constructor: (@paths) ->

  load: (callback) ->
    @locales = {}

    find 'yml', @paths, asyncErrorTrap callback, (files) =>
      throw err if err?

      readFiles files, asyncErrorTrap callback, (docs) =>
        throw err if err?

        for path, content of docs
          @deepMerge @locales, yaml.load content

        @languages = @locales.sortedKeys()
        callback?()

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

module.exports = Loader
