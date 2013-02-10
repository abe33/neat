require '../../test_helper'

{readFiles, writeFiles} = require '../../../lib/processing/core'

describe 'processing promise', ->
  beforeEach ->
    addPromiseMatchers this
    addFileMatchers this

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

  describe 'writeFiles', ->
    it 'should exists', ->
      expect(writeFiles).toBeDefined()

    describe 'when called with a files buffer', ->
      beforeEach ->
        @files = {}
        @files[tmp 'processing/foo.coffee'] = 'foo.coffee'
        @files[tmp 'processing/foo.js'] = 'foo.js'
        @writeFiles = writeFiles @files

      afterEach -> clearTmp 'processing'

      it 'should return a promise', ->
        expect(@writeFiles).toBePromise()

      promise(-> @writeFiles)
      .should.beFulfilled()
      .should 'have written the files on the file system', ->
        expect(tmp 'processing/foo.coffee').toContain('foo.coffee')
        expect(tmp 'processing/foo.js').toContain('foo.js')
