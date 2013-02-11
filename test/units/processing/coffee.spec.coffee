require '../../test_helper'

coffee = require '../../../lib/processing/coffee'

describe 'coffee processing promise', ->
  beforeEach ->
    addPromiseMatchers this

  describe 'compile', ->
    it 'should exists', ->
      expect(coffee.compile).toBeDefined()

    describe 'when called with options', ->
      beforeEach ->
        @compile = coffee.compile bare: true

      it 'should return a function', ->
        expect(typeof @compile).toBe('function')

      describe 'the returned function', ->
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
            .toBe("In file 'foo.coffee': Parse error on line 1: Unexpected 'TERMINATOR'")

