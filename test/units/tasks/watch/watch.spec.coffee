require '../../../test_helper'

Neat = require '../../../../lib/neat'
Watch = Neat.require 'tasks/watch/watch'

describe 'Watch', ->
  given 'regexp', -> /(src\/tasks\/watch)\/.*\.coffee$/
  given 'options', -> option: 'irrelevant'
  given 'block', -> (f, m, g) -> ["#{g}/*.coffee"]

  given 'validPath', -> Neat.resolve 'src/tasks/watch/watch.coffee'
  given 'additionalReturnedPath', ->
    Neat.resolve 'src/tasks/watch/watcher.coffee'
  given 'invalidPath', -> Neat.resolve 'src/watchers/compile.coffee'

  subject 'watch', -> new Watch @regexp, @options, @block

  it 'should exist', ->
    expect(@watch).toBeDefined()

  it 'should have stored the passed-in data', ->
    expect(@watch.regexp).toBe(@regexp)
    expect(@watch.options).toBe(@options)
    expect(@watch.block).toBe(@block)

  describe '#match', ->
    describe 'when called with a path', ->
      it 'should return true if the file is matched by the watch', ->
        expect(@watch.match @validPath).toBeTruthy()
        expect(@watch.match @invalidPath).toBeFalsy()

  describe '#outputPaths', ->
    describe 'for a watch with a block', ->
      given 'promise', -> @watch.outputPathsFor @validPath

      waiting -> @promise

      promise()
      .should.beFulfilled()
      .should 'returns an array of matching files', (paths) ->
        expect(paths).toContain(@validPath)
        expect(paths).toContain(@additionalReturnedPath)
        expect(paths).not.toContain(@invalidPath)

    describe 'for a watch without block', ->
      subject 'watch', -> new Watch @regexp

      given 'promise', -> @watch.outputPathsFor @validPath

      waiting -> @promise

      promise()
      .should.beFulfilled()
      .should 'returns an array of matching files', (paths) ->
        expect(paths).toContain(@validPath)
        expect(paths).not.toContain(@additionalReturnedPath)
        expect(paths).not.toContain(@invalidPath)
