fs = require 'fs'
path = require 'path'
glob = require 'glob'
Q = require 'q'
{compile:compileCoffee} = require 'coffee-script'
Neat = require '../../neat'
Build = require './build'
logs = Neat.require 'utils/logs'
processors = Neat.require 'processing'

class Builder
  constructor: ->
    @builds = []
    @unit = Q.defer()
  init: ->
    @loadNeatfile()
    .then(@compileNeatfile())
    .then (neatfile) =>
      logs.puts logs.yellow 'Neatfile loaded'
      load = (path) -> fs.readFileSync Neat.rootResolve path

      build = (name, block) =>
        b = new Build name
        block.call this, b
        @builds.push b

      eval "#{@getLocals(processors)}\n#{neatfile}"
    .then =>
      logs.puts logs.yellow 'Neatfile evaluated'
      runBuild = (build) -> -> build.process()
      promise = Q.fcall ->
      promise = promise.then runBuild build for build in @builds
      promise
    .fail (err) ->
      console.error err.message
      console.error err.stack

  glob: (path) ->
    defer = Q.defer()
    glob path, defer.makeNodeResolver()
    defer.promise

  getLocals: (processors) ->
    lines = []
    processors.each (name,collection) ->
      lines.push "var #{name} = processors.#{name};"

    lines.join '\n'

  loadNeatfile: =>
    defer = Q.defer()

    fs.readFile "#{Neat.root}/Neatfile", (err, neatfile) ->
      return defer.reject err if err?
      defer.resolve neatfile.toString()

    defer.promise

  compileNeatfile: -> (neatfile) => compileCoffee neatfile

module.exports = Builder
