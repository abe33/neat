require '../../test_helper'
Q = require 'q'
fs = require 'fs'
path = require 'path'

core = require '../../../lib/processing/core'

describe 'core processing promise', ->
  beforeEach ->
    addPromiseMatchers this
    addFileMatchers this

  describe 'readFiles', ->
    it 'should exists', ->
      expect(core.readFiles).toBeDefined()

    describe 'when called without paths', ->
      it 'should raise an exception', ->
        expect(-> core.readFiles()).toThrow()

    describe 'when called with paths that exists', ->
      beforeEach ->
        @readFiles = core.readFiles [
          fixture 'processing/file.coffee'
          fixture 'processing/file.js'
        ]
        @expectedResult = {}
        coffeePath = fixture 'processing/file.coffee'
        jsPath = fixture 'processing/file.js'
        @expectedResult[coffeePath] = "# this is file.coffee\n"
        @expectedResult[jsPath] = "// this is file.js\n"

      it 'should return a promise', ->
        expect(@readFiles).toBePromise()

      promise(-> @readFiles)
      .should.beFulfilled()
      .should.returns 'a hash with the paths content', -> @expectedResult

    describe 'when called with paths that does not exists', ->
      beforeEach ->
        @readFiles = core.readFiles [
          fixture 'processing/foo.coffee'
          fixture 'processing/bar.js'
        ]

      promise(-> @readFiles).should.beRejected()

  describe 'writeFiles', ->
    it 'should exists', ->
      expect(core.writeFiles).toBeDefined()

    describe 'when called without a valid file buffer', ->
      it 'should raise an exception', ->
        expect(-> core.writeFiles 5).toThrow()
        expect(-> core.writeFiles 'foo').toThrow()
        expect(-> core.writeFiles null).toThrow()

    describe 'when called with a files buffer', ->
      beforeEach ->
        @files = {}
        @files[tmp 'processing/foo.coffee'] = 'foo.coffee'
        @files[tmp 'processing/foo.js'] = 'foo.js'
        @writeFiles = core.writeFiles @files

      afterEach -> clearTmp 'processing'

      it 'should return a promise', ->
        expect(@writeFiles).toBePromise()

      promise(-> @writeFiles)
      .should.beFulfilled()
      .should 'have written the files on the file system', ->
        expect(tmp 'processing/foo.coffee').toContain('foo.coffee')
        expect(tmp 'processing/foo.js').toContain('foo.js')

  describe 'processExtension', ->
    it 'should exists', ->
      expect(core.processExtension).toBeDefined()

    describe 'called without arguments', ->
      it 'should raise an exception', ->
        expect(-> core.processExtension()).toThrow()

    describe 'called with only an extension', ->
      it 'should raise an exception', ->
        expect(-> core.processExtension 'coffee').toThrow()

    describe 'called with an extension and a promise returning function', ->
      beforeEach ->
        @processor = core.processExtension 'coffee', (buffer) ->
          Q.fcall ->
            newBuffer = {}
            buffer.each (k,v) -> newBuffer["#{k}_foo"] = 'I want coffee'
            newBuffer

      it 'should return a promise return function', ->
        expect(typeof @processor).toBe('function')

      describe 'and the returned function called without file buffer', ->
        it 'should raise an exception', ->
          expect(=> @processor 5).toThrow()
          expect(=> @processor 'foo').toThrow()
          expect(=> @processor null).toThrow()

      describe 'and the returned function called with a buffer', ->
        beforeEach ->
          @files = {}
          @files[tmp 'processing/foo.coffee'] = 'foo.coffee'
          @files[tmp 'processing/foo.js'] = 'foo.js'
          @processCoffee = @processor @files

        it 'should return a promise', ->
          expect(@processCoffee).toBePromise()

        promise(-> @processCoffee)
        .should.beFulfilled()
        .should 'have processed the file with corresponding extension', (r) ->
          expect(r[tmp 'processing/foo.coffee']).toBeUndefined()
          expect(r[tmp 'processing/foo.js_foo']).toBeUndefined()

          expect(r[tmp 'processing/foo.coffee_foo']).toBe('I want coffee')
          expect(r[tmp 'processing/foo.js']).toBe('foo.js')

  describe 'join', ->
    it 'should exists', ->
      expect(core.join).toBeDefined()

    describe 'when called without a file name', ->
      it 'should raise an exception', ->
        expect(-> core.join()).toThrow()

    describe 'when called with a file name', ->
      beforeEach ->
        @joiner = core.join 'foo.coffee'

      it 'should return a function', ->
        expect(typeof @joiner).toBe('function')

      describe 'the returned function called without a valid file buffer', ->
        it 'should raise an exception', ->
          expect(=> @joiner 5).toThrow()
          expect(=> @joiner 'foo').toThrow()
          expect(=> @joiner null).toThrow()

      describe 'the returned function called with a buffer', ->
        beforeEach ->
          @join = @joiner {
            'file.coffee': 'foo'
            'file.js': 'bar'
          }

        it 'should return a promise', ->
          expect(@join).toBePromise()

        promise(-> @join)
        .should.beFulfilled()
        .should.returns 'a new buffer with only one file with all content', ->
          'foo.coffee': 'foo\nbar'

  describe 'relocate', ->
    it 'should exists', ->
      expect(core.relocate).toBeDefined()

    describe 'when called without the from argument', ->
      it 'should raise an exception', ->
        expect(-> core.relocate()).toThrow()

    describe 'when called without the to argument', ->
      it 'should raise an exception', ->
        expect(-> core.relocate 'foo').toThrow()







