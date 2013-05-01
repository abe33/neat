require '../../test_helper'
{resolve} = require "path"
root = resolve __dirname, '../../../'

_ = require "#{root}/lib/utils/matchers"

describe 'equalTo', ->
  it 'should return true when elements match the strict equality', ->
    a = ['10', 10, 10]
    b = [20, 20, 20]

    expect(a.some _.equalTo 10).toBeTruthy()
    expect(b.some _.equalTo 10).toBeFalsy()

    expect(a.every _.equalTo 10).toBeFalsy()
    expect(b.every _.equalTo 20).toBeTruthy()

describe 'isType', ->
  it 'should returns true when typeof match the type', ->
    a = ['foo', 10, false]
    b = [20, 20, 20]

    expect(a.some _.isType 'string').toBeTruthy()
    expect(b.some _.isType 'string').toBeFalsy()

    expect(a.every _.isType 'number').toBeFalsy()
    expect(b.every _.isType 'number').toBeTruthy()

describe 'anyOf', ->
  it 'should returns true when any of the matchers match', ->
    a = ['foo', 10, false]
    b = [20, 20, 10]

    matcher = _.anyOf 20, _.isType('string')

    expect(a.some matcher).toBeTruthy()
    expect(b.some matcher).toBeTruthy()

    expect(a.every matcher).toBeFalsy()
    expect(b.every matcher).toBeFalsy()

describe 'allOf', ->
  it 'should returns true when all of the matchers match', ->
    a = ['foo', 10, false]
    b = [20, 20, '10']

    matcher = _.allOf 'foo', _.isType('string')

    expect(a.some matcher).toBeTruthy()
    expect(b.some matcher).toBeFalsy()

    expect(a.every matcher).toBeFalsy()
    expect(b.every matcher).toBeFalsy()

describe 'isNot', ->
  describe 'when called with a matcher', ->
    it 'should inverse the result of the passed-in matcher', ->

      a = ['foo', 10, false]
      b = [20, 20, 20]

      expect(a.some _.isNot _.equalTo 20).toBeTruthy()
      expect(b.some _.isNot _.equalTo 20).toBeFalsy()

      expect(a.every _.isNot _.equalTo 20).toBeTruthy()
      expect(b.every _.isNot _.equalTo 20).toBeFalsy()

  describe 'when called with a value', ->
    it 'should return true if the element isnt the value', ->
      a = ['foo', 10, false]
      b = [20, 20, 20]

      expect(a.some _.isNot 20).toBeTruthy()
      expect(b.some _.isNot 20).toBeFalsy()

      expect(a.every _.isNot 20).toBeTruthy()
      expect(b.every _.isNot 20).toBeFalsy()

describe 'isNull', ->
  it 'should match null elements', ->

    a = [0, null, 'foo']
    b = [10, 20, 30]

    expect(a.some _.isNull()).toBeTruthy()
    expect(b.some _.isNull()).toBeFalsy()

    expect(a.every _.isNull()).toBeFalsy()
    expect(b.every _.isNull()).toBeFalsy()

describe 'isNotNull', ->
  it 'should match non null elements', ->

    a = [0, null, 'foo']
    b = [10, 20, 30]

    expect(a.some _.isNotNull()).toBeTruthy()
    expect(b.some _.isNotNull()).toBeTruthy()

    expect(a.every _.isNotNull()).toBeFalsy()
    expect(b.every _.isNotNull()).toBeTruthy()

describe 'hasProperty', ->
  it 'should match when an object contains the given property', ->
    a = [
      {foo: 10, bar: 20},
      {foo: null},
      {foo: 10, baz: 20},
    ]

    expect(a.some _.hasProperty 'foo').toBeTruthy()
    expect(a.some _.hasProperty 'bar').toBeTruthy()

    expect(a.every _.hasProperty 'foo').toBeTruthy()
    expect(a.every _.hasProperty 'bar').toBeFalsy()

  it 'should match the value of the given
      property with the specified matcher'.squeeze(), ->

    a = [
      {foo: 10, bar: 20},
      {foo: 20},
      {foo: 30, baz: 20},
    ]

    expect(a.some _.hasProperty 'foo', 10).toBeTruthy()
    expect(a.some _.hasProperty 'foo', _.equalTo 10).toBeTruthy()

    expect(a.every _.hasProperty 'foo', 10).toBeFalsy()
    expect(a.every _.hasProperty 'foo', _.equalTo 10).toBeFalsy()

describe 'hasProperties', ->
  it 'should test for either property existence or value
      according to the arguments'.squeeze(), ->

    a = [
      {foo: 10, bar: 20},
      {foo: null},
      {foo: 30, baz: 20},
    ]

    expect(a.some _.hasProperties 'foo', 'bar').toBeTruthy()
    expect(a.some _.hasProperties 'foo', bar:20).toBeTruthy()
    expect(a.some _.hasProperties 'foo', bar: _.equalTo 20).toBeTruthy()

    expect(a.every _.hasProperties 'foo').toBeTruthy()
    expect(a.every _.hasProperties 'foo', 'bar').toBeFalsy()
    expect(a.every _.hasProperties 'foo', bar:20).toBeFalsy()
    expect(a.every _.hasProperties 'foo', bar: _.equalTo 20).toBeFalsy()

describe 'quacksLike', ->
  it 'should perform a duck test on the elements'.squeeze(), ->

    a = [
      {foo: 10, bar: 20},
      {foo: 20},
      {foo: 30, baz: 20},
    ]

    def = __definition__:
      foo: 'number'
      bar: 'number'

    expect(a.some _.quacksLike def).toBeTruthy()
    expect(a.every _.quacksLike def).toBeFalsy()

describe 'greaterThan', ->
  it 'should match number above the specified value', ->
    a = [0, 10, 20, 30, 40]

    expect(a.some _.greaterThan 10).toBeTruthy()
    expect(a.some _.greaterThan 60).toBeFalsy()

    expect(a.every _.greaterThan 0).toBeFalsy()
    expect(a.every _.greaterThan -1).toBeTruthy()

describe 'greaterThanOrEqualTo', ->
  it 'should match number equal or above the specified value', ->
    a = [0, 10, 20, 30, 40]

    expect(a.some _.greaterThanOrEqualTo 10).toBeTruthy()
    expect(a.some _.greaterThanOrEqualTo 60).toBeFalsy()

    expect(a.every _.greaterThanOrEqualTo 0).toBeTruthy()

describe 'lowerThan', ->
  it 'should match number below the specified value', ->
    a = [0, 10, 20, 30, 40]

    expect(a.some _.lowerThan 10).toBeTruthy()
    expect(a.some _.lowerThan 0).toBeFalsy()

    expect(a.every _.lowerThan 40).toBeFalsy()
    expect(a.every _.lowerThan 50).toBeTruthy()

describe 'lowerThanOrEqualTo', ->
  it 'should match number equal or below the specified value', ->
    a = [0, 10, 20, 30, 40]

    expect(a.some _.lowerThanOrEqualTo 10).toBeTruthy()
    expect(a.some _.lowerThanOrEqualTo 0).toBeTruthy()

    expect(a.every _.lowerThanOrEqualTo 40).toBeTruthy()
