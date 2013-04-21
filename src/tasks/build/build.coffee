glob = require 'glob'
Q = require 'q'
Neat = require '../../neat'
processors = Neat.require 'processing'

class Build
  constructor: (@name) ->
    @sources = []
    @processors = []

  source: (path) -> @sources.push Neat.rootResolve path

  do: (promise) ->
    @processors.push promise
    this

  then: Build::do

  process: ->
    @findSources()
    .then (files) =>
      @loadBuffer files
    .then (buffer) =>
      @processBuffer buffer

  findSources: ->
    findOneSources = (path) ->
      defer = Q.defer()
      glob path, {}, (err, results) ->
        return defer.reject err if err?
        defer.resolve results

      defer.promise

    Q.all(findOneSources(source) for source in @sources)
    .then (paths) -> paths.flatten().uniq()

  loadBuffer: (paths) ->
    processors.core.readFiles(paths)

  processBuffer: (buffer) ->
    promise = Q.fcall(-> buffer)
    promise = promise.then(processor) for processor in @processors
    promise

  toString: -> "[Build: #{@name}]"

module.exports = Build
