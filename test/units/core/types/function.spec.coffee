require '../../../test_helper'
require '../../../../lib/core'

describe 'Function.isAsync', ->
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

describe 'Function::signature', ->
  it 'should return the signature of the function', ->
    f = (a,b,c) ->
    expect(f.signature()).toEqual(['a','b','c'])

  it 'should return an empty array for empty functions', ->
    f = ->
    expect(f.signature()).toEqual([])
