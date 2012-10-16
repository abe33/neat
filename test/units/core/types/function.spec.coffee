require '../../../../lib/core'
require '../../../test_helper'
require '../../../helpers/core/types/function_helper'

describe 'Function', ->
  beforeEach -> addFunctionMatchers this

  describe '.isAsync', ->
    describe 'when the passed-in function has its last
              arguments named callback'.squeeze(), ->
      it 'should return true', ->
        expect(Function.isAsync (callback) -> ).toBeTruthy()
        expect(Function.isAsync (a,b,c,callback) -> ).toBeTruthy()

    describe 'when the passed-in function does not have its last arguments
              named callback'.squeeze(), ->
      it 'should return false', ->
        expect(Function.isAsync -> ).toBeFalsy()
        expect(Function.isAsync (callback, a) -> ).toBeFalsy()

      describe 'but have an ambigous use of callback in its source', ->
        it 'should return false', ->
          fn = ->
            f = (callback) ->
              foo(callback)
          expect(Function.isAsync fn).toBeFalsy()

  describe '::signature', ->
    it 'should return the signature of the function', ->
      f = (a,b,c) ->
      expect(f.signature()).toEqual(['a','b','c'])

    it 'should return an empty array for empty functions', ->
      f = ->
      expect(f.signature()).toEqual([])

  describe '::isAsync', ->
    describe 'on a function that has its only argument named callback', ->
      it 'should return true', ->
        expect((callback) ->).toBeAsync()

    describe 'on a function that has its last
              arguments named callback'.squeeze(), ->
      it 'should return true', ->
        expect((a,b,c,callback) ->).toBeAsync()

    describe 'on a function that does not have any arguments', ->
      it 'should return false', ->
        expect(->).not.toBeAsync()

    describe 'on a function that does not have its last arguments
              named callback'.squeeze(), ->
      it 'should return false', ->
        expect((callback, a) ->).not.toBeAsync()

      describe 'but have an ambigous use of callback in its source', ->
        it 'should return false', ->
          fn = ->
            f = (callback) ->
              foo(callback)
          expect(fn).not.toBeAsync()

  describe '::callAsync', ->
    describe 'on a function that is not asynchronous', ->
      it 'should call the function and then the callback', (done) ->
        fn = (a,b) -> a + b

        fn.callAsync null, 5, 10, (res) ->
          expect(res).toBe(15)
          done()

    describe 'on a function that is asynchronous', ->
      it 'should call the function and then the callback', (done) ->
        fn = (a,b,callback) ->
          setTimeout ->
            callback? a + b
          , 100

        fn.callAsync null, 5, 10, (res) ->
          expect(res).toBe(15)
          done()

  describe '::applyAsync', ->
    describe 'on a function that is not asynchronous', ->
      it 'should call the function and then the callback', (done) ->
        fnResult = false
        fn = (a,b) -> a + b

        fn.applyAsync null, [5, 10], (res) ->
          expect(res).toBe(15)
          done()

    describe 'on a function that is asynchronous', ->
      it 'should call the function and then the callback', (done) ->
        fnResult = false
        fn = (a,b,callback) ->
          setTimeout ->
            callback? a + b
          , 100

        fn.applyAsync null, [5, 10], (res) ->
          expect(res).toBe(15)
          done()
