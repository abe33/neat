require '../../test_helper'

{readFiles} = require '../../../lib/processing/core'

describe 'processing promise', ->
  beforeEach -> addPromiseMatchers this
  describe 'readFiles', ->
    it 'should exists', ->
      expect(readFiles).toBeDefined()

    describe 'when called with paths that exists', ->
      beforeEach ->
        @readFiles = readFiles [
          fixture 'processing/file.coffee'
          fixture 'processing/file.js'
        ]
        @expectedResult = {}
        @expectedResult[fixture 'processing/file.coffee'] = "# this is file.coffee\n"
        @expectedResult[fixture 'processing/file.js'] = "// this is file.js\n"

      it 'should return a promise', ->
        expect(@readFiles).toBePromise()

      promise(-> @readFiles)
      .should.beFulfilled()
      .should.returns 'a hash with the paths content', -> @expectedResult

    describe 'when called with paths that does not exists', ->
      beforeEach ->
        @readFiles = readFiles [
          fixture 'processing/foo.coffee'
          fixture 'processing/bar.js'
        ]

      promise(-> @readFiles).should.beRejected()
