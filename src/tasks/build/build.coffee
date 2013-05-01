glob = require 'glob'
Q = require 'q'
Neat = require '../../neat'
logs = Neat.require 'utils/logs'
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

  fail: (handler) ->
    @failHandler = handler
    this

  process: ->
    promise = @findSources()
    .then (files) =>
      @loadBuffer files
    .then (buffer) =>
      @processBuffer buffer
    .then =>
      logs.info logs.green "#{@name} build completed"

    promise.fail @failHandler if @failHandler?
    promise

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
    processors.readFiles(paths)

  processBuffer: (buffer) ->
    promise = Q.fcall(-> buffer)
    for processor in @processors
      promise = promise.then(processor).fail (err) ->
        console.log "failed in processor #{processor} with #{err}\n#{err.stack}"
    promise

  toString: -> "[Build: #{@name}]"

module.exports = Build
