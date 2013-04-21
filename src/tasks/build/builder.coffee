fs = require 'fs'
path = require 'path'
glob = require 'glob'
Q = require 'q'
{compile} = require 'coffee-script'
Neat = require '../../neat'
Build = require './build'
processors = Neat.require 'processing'

class Builder
  constructor: ->
    @builds = []
    @unit = Q.defer()
  init: ->
    @loadNeatfile()
    .then(@compileNeatfile())
    .then (neatfile) =>

      build = (name, block) =>
        b = new Build name
        block.call this, b
        @builds.push b

      eval "#{@getLocals(processors)}\n#{neatfile}"
    .then =>
      runBuild = (build) -> -> build.process()
      promise = Q.fcall ->
      promise = promise.then runBuild build for build in @builds
      promise

  glob: (path) ->
    defer = Q.defer()
    glob path, defer.makeNodeResolver()
    defer.promise

  getLocals: (processors) ->
    lines = []
    processors.each (pkg,collection) ->
      collection.each (name, processor) ->
        lines.push "var #{name} = processors.#{pkg}.#{name};"

    lines.join '\n'

  loadNeatfile: =>
    defer = Q.defer()

    fs.readFile "#{Neat.root}/Neatfile", (err, neatfile) ->
      return defer.reject err if err?
      defer.resolve neatfile.toString()

    defer.promise

  compileNeatfile: -> (neatfile) => compile neatfile

module.exports = Builder
