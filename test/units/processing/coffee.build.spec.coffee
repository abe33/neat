require '../../test_helper'

coffee = require '../../../lib/processing/coffee.build'

describe 'coffee processing promise', ->
  beforeEach ->
    addPromiseMatchers this

  describe 'compile', ->
    it 'should exists', ->
      expect(coffee.compile).toBeDefined()

    describe 'when called without options', ->
      beforeEach ->
        @compile = coffee.compile()

      it 'should return a function', ->
        expect(typeof @compile).toBe('function')

      describe 'the returned function', ->

        describe 'when called without a valid file buffer', ->
          it 'should raise an exception', ->
            expect(=> @compile 5).toThrow()
            expect(=> @compile 'foo').toThrow()
            expect(=> @compile null).toThrow()

        describe 'called with a file buffer', ->
          beforeEach ->
            @compileBuffer = @compile 'foo.coffee': 'f = ->'

            @expectedResult = '(function() {\n
  var f;\n\n
  f = function() {};\n\n
}).call(this);\n'

          it 'should return a promise', ->
            expect(@compileBuffer).toBePromise()

          promise(-> @compileBuffer)
          .should.beFulfilled()
          .should 'compile the files content through coffee compiler', (r) ->
            expect(r['foo.js']).toBe(@expectedResult)

        describe 'called with content that breaks the compiler', ->
          beforeEach ->
            @compileBuffer = @compile 'foo.coffee': 'f = -'

          promise(-> @compileBuffer)
          .should.beRejected()
          .should.failWith 'the file name and line number', (err) ->
            expect(err.message)
            .toBe("In file 'foo.coffee': unexpected TERMINATOR")

    describe 'when called with options', ->
      beforeEach ->
        @compile = coffee.compile bare: true

      it 'should return a function', ->
        expect(typeof @compile).toBe('function')

      describe 'the returned function', ->

        describe 'when called without a valid file buffer', ->
          it 'should raise an exception', ->
            expect(=> @compile 5).toThrow()
            expect(=> @compile 'foo').toThrow()
            expect(=> @compile null).toThrow()

        describe 'called with a file buffer', ->
          beforeEach ->
            @compileBuffer = @compile 'foo.coffee': 'f = ->'

            @expectedResult = 'var f;\n\nf = function() {};\n'

          it 'should return a promise', ->
            expect(@compileBuffer).toBePromise()

          promise(-> @compileBuffer)
          .should.beFulfilled()
          .should 'compile the files content through coffee compiler', (r) ->
            expect(r['foo.js']).toBe(@expectedResult)

        describe 'called with content that breaks the compiler', ->
          beforeEach ->
            @compileBuffer = @compile 'foo.coffee': 'f = -'

          promise(-> @compileBuffer)
          .should.beRejected()
          .should.failWith 'the file name and line number', (err) ->
            expect(err.message)
            .toBe("In file 'foo.coffee': unexpected TERMINATOR")

  describe 'annotate', ->
    it 'should exists', ->
      expect(coffee.annotate).toBeDefined()

    describe 'when called without a valid file buffer', ->
      it 'should raise an exception', ->
        expect(=> coffee.annotate 5).toThrow()
        expect(=> coffee.annotate 'foo').toThrow()
        expect(=> coffee.annotate null).toThrow()

    describe 'when called with a file buffer', ->
      beforeEach ->
        @annotateBuffer = coffee.annotate
          'foo.coffee': loadFixture 'processing/coffee/class.coffee'

      it 'should return a promise', ->
        expect(@annotateBuffer).toBePromise()

      promise(-> @annotateBuffer)
      .should.beFulfilled()
      .should.returns 'the buffer with annotated content', ->
        'foo.coffee': loadFixture 'processing/coffee/class.annotated.coffee'

  describe 'exportsToPackage', ->
    it 'should exists', ->
      expect(coffee.exportsToPackage).toBeDefined()

    describe 'when called without package', ->
      it 'should raise an exception', ->
        expect(-> coffee.exportsToPackage()).toThrow()

    describe 'when called with a package name', ->
      beforeEach ->
        @exporterGenerator = coffee.exportsToPackage 'path.to.package'

      it 'should return a function', ->
        expect(typeof @exporterGenerator).toBe('function')

      describe 'the returned function', ->
        describe 'when called without a valid file buffer', ->
          it 'should raise an exception', ->
            expect(=> @exporterGenerator 5).toThrow()
            expect(=> @exporterGenerator 'foo').toThrow()
            expect(=> @exporterGenerator null).toThrow()

        describe 'when called with a file buffer', ->
          beforeEach ->
            @exportsToPackage = @exporterGenerator
              'foo.coffee': loadFixture 'processing/coffee/exports.coffee'

          it 'should return a promise', ->
            expect(@exportsToPackage).toBePromise()

          fixture = 'processing/coffee/exports.exported.coffee'
          promise(-> @exportsToPackage)
          .should.beFulfilled()
          .should.returns 'the buffer with exports replaced with package', ->
            'foo.coffee': loadFixture(fixture).strip()

  describe 'stripRequires', ->
    it 'should exists', ->
      expect(coffee.stripRequires).toBeDefined()

    describe 'when called without a valid file buffer', ->
      it 'should raise an exception', ->
        expect(=> coffee.stripRequires 5).toThrow()
        expect(=> coffee.stripRequires 'foo').toThrow()
        expect(=> coffee.stripRequires null).toThrow()

    describe 'when called with a file buffer', ->
      beforeEach ->
        @stripRequires = coffee.stripRequires
          'foo.coffee': loadFixture 'processing/coffee/requires.coffee'

      it 'should return a promise', ->
        expect(@stripRequires).toBePromise()

      promise(-> @stripRequires)
      .should.beFulfilled()
      .should.returns 'the buffer with requires removed', ->
        'foo.coffee': loadFixture 'processing/coffee/requires.stripped.coffee'






