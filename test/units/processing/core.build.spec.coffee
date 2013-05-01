require '../../test_helper'
Q = require 'q'
fs = require 'fs'
path = require 'path'

core = require '../../../lib/processing/core.build'

describe 'core processing promise', ->
  beforeEach ->
    addPromiseMatchers this

  describe 'readFiles', ->
    it 'should exists', ->
      expect(core.readFiles).toBeDefined()

    describe 'when called without paths', ->
      it 'should raise an exception', ->
        expect(-> core.readFiles()).toThrow()

    describe 'when called with paths that exists', ->
      given 'expectedResult', ->
        {}.tap (o) ->
          coffeePath = fixture 'processing/file.coffee'
          jsPath = fixture 'processing/file.js'
          o[coffeePath] = "# this is file.coffee\n"
          o[jsPath] = "// this is file.js\n"

      subject 'promise', ->
        core.readFiles [
          fixture 'processing/file.coffee'
          fixture 'processing/file.js'
        ]

      it 'should return a promise', ->
        expect(@promise).toBePromise()

      promise()
      .should.beFulfilled()
      .should.returns 'a hash with the paths content', -> @expectedResult

    describe 'when called with paths that does not exists', ->
      subject 'promise', ->
        core.readFiles [
          fixture 'processing/foo.coffee'
          fixture 'processing/bar.js'
        ]

      promise().should.beRejected()

  describe 'writeFiles', ->
    it 'should exists', ->
      expect(core.writeFiles).toBeDefined()

    describe 'when called without a valid file buffer', ->
      it 'should raise an exception', ->
        expect(-> core.writeFiles 5).toThrow()
        expect(-> core.writeFiles 'foo').toThrow()
        expect(-> core.writeFiles null).toThrow()

    describe 'when called with a files buffer', ->
      given 'files', ->
        {}.tap (o) ->
          o[tmp 'processing/foo.coffee'] = 'foo.coffee'
          o[tmp 'processing/foo.js'] = 'foo.js'

      subject 'promise', -> core.writeFiles @files

      beforeEach ->
        spyOn(fs, "mkdir").andCallFake (p,cb) -> cb?()
        spyOn(fs, "writeFile").andCallFake (p,c,cb) -> cb?()

      it 'should return a promise', ->
        expect(@promise).toBePromise()

      promise()
      .should.beFulfilled()
      .should 'have written the files on the file system', ->
        expect(fs.writeFile).toHaveBeenCalled()

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
        @processor = core.processExtension 'coffee', (unit) ->
          unit.then (buffer) ->
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

    describe 'when called with both arguments', ->
      subject 'promiseGenerator', -> core.relocate '/foo', '/bar'

      it 'should return a promise returning function', ->
        expect(typeof @promiseGenerator).toBe('function')

      describe 'the returned function called without a valid file buffer', ->
        it 'should raise an exception', ->
          expect(=> @promiseGenerator 5).toThrow()
          expect(=> @promiseGenerator 'foo').toThrow()
          expect(=> @promiseGenerator null).toThrow()


      describe 'the returned function called with a buffer', ->
        given 'expectedResult', ->
          {
            '/bar/file.coffee': 'foo'
            '/bar/file.js': 'bar'
            '/baz/file.js': 'baz'
          }

        subject 'promise', ->
          @promiseGenerator {
            '/foo/file.coffee': 'foo'
            '/foo/file.js': 'bar'
            '/baz/file.js': 'baz'
          }

        it 'should return a promise', ->
          expect(@promise).toBePromise()

        promise()
        .should.beFulfilled()
        .should.returns 'a hash with the path changed', -> @expectedResult

  describe 'remove', ->
    beforeEach ->
      spyOn(fs, 'unlink').andCallFake (path, cb) -> cb?()
      spyOn(fs, 'rmdir').andCallFake (path, cb) -> cb?()

    it 'should exists', ->
      expect(core.remove).toBeDefined()

    describe 'when called without the path argument', ->
      it 'should raise an exception', ->
        expect(-> core.remove()).toThrow()

    describe 'when called with path argument', ->
      subject 'promiseGenerator', -> core.remove '/foo'
      given 'buffer', ->
        {
          '/foo/file.coffee': 'foo'
          '/foo/file.js': 'bar'
          '/baz/file.js': 'baz'
        }

      it 'should return a promise returning function', ->
        expect(typeof @promiseGenerator).toBe('function')

      describe 'the returned function called without a valid file buffer', ->
        it 'should raise an exception', ->
          expect(=> @promiseGenerator 5).toThrow()
          expect(=> @promiseGenerator 'foo').toThrow()
          expect(=> @promiseGenerator null).toThrow()

      describe 'for a directory', ->
        given 'promiseGenerator', ->
          core.remove 'test/fixtures/processing'

        subject 'promise', -> @promiseGenerator @buffer

        promise()
        .should.beFulfilled()
        .should 'have called fs.', ->
          expect(fs.rmdir).toHaveBeenCalled()

      describe 'for a file', ->
        given 'promiseGenerator', ->
          core.remove 'test/fixtures/processing/file.coffee'

        subject 'promise', -> @promiseGenerator @buffer

        promise()
        .should.beFulfilled()
        .should 'have called fs.unlink', ->
          expect(fs.unlink).toHaveBeenCalled()

  describe 'fileHeader', ->
    it 'should exists', ->
      expect(core.fileHeader).toBeDefined()

    describe 'when called without the header argument', ->
      it 'should raise an exception', ->
        expect(-> core.fileHeader()).toThrow()

    describe 'when called with header argument', ->
      subject 'promiseGenerator', -> core.fileHeader 'Header'
      given 'buffer', ->
        {
          '/foo/file.coffee': 'foo'
          '/foo/file.js': 'bar'
          '/baz/file.js': 'baz'
        }

      it 'should return a promise returning function', ->
        expect(typeof @promiseGenerator).toBe('function')

      describe 'the returned function called without a valid file buffer', ->
        it 'should raise an exception', ->
          expect(=> @promiseGenerator 5).toThrow()
          expect(=> @promiseGenerator 'foo').toThrow()
          expect(=> @promiseGenerator null).toThrow()

      subject 'promise', -> @promiseGenerator @buffer

      promise()
      .should.beFulfilled()
      .should 'returns a buffer decorated with the header', (buffer) ->
        expect(buffer['/foo/file.coffee'])
        .toContain('Header\nfoo')

  describe 'fileFooter', ->
    it 'should exists', ->
      expect(core.fileFooter).toBeDefined()

    describe 'when called without the header argument', ->
      it 'should raise an exception', ->
        expect(-> core.fileFooter()).toThrow()

    describe 'when called with header argument', ->
      subject 'promiseGenerator', -> core.fileFooter 'footer'
      given 'buffer', ->
        {
          '/foo/file.coffee': 'foo'
          '/foo/file.js': 'bar'
          '/baz/file.js': 'baz'
        }

      it 'should return a promise returning function', ->
        expect(typeof @promiseGenerator).toBe('function')

      describe 'the returned function called without a valid file buffer', ->
        it 'should raise an exception', ->
          expect(=> @promiseGenerator 5).toThrow()
          expect(=> @promiseGenerator 'foo').toThrow()
          expect(=> @promiseGenerator null).toThrow()

      subject 'promise', -> @promiseGenerator @buffer

      promise()
      .should.beFulfilled()
      .should 'returns a buffer decorated with the footer', (buffer) ->
        expect(buffer['/foo/file.coffee'])
        .toContain('foo\nfooter\n')







