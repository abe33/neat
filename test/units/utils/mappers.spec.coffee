require '../../test_helper'
{resolve} = require "path"
root = resolve __dirname, '../../../'

_ = require "#{root}/lib/utils/mappers"

describe 'property', ->
  it 'should map the given property value in the results', ->

    res = [
      {foo: 10},
      {foo: 'bar'},
      {foo: false}
    ].map _.property 'foo'

    expect(res).toEqual([10, 'bar', false])

  it 'should map to undefined if the element does
      not have the given property'.squeeze(), ->

    res = [
      {foo: 10},
      {},
      10
    ].map _.property 'foo'

    expect(res).toEqual([10, undefined, undefined])

  it 'should map the mapped property', ->

    res = [
      {foo: 'foo'},
      {foo: 'bar'},
      {foo: 'baz'}
    ].map _.property 'foo', _.length()

    expect(res).toEqual([3,3,3])

describe 'first', ->
  it 'should map the given value at first index in the element', ->

    res = [
      [10, 20],
      ['foo', 'bar'],
      [true, false]
    ].map _.first()

    expect(res).toEqual([10, 'foo', true])

  it 'should apply the passed-in mapper to the first index', ->

    res = [
      [{foo:10}, 20],
      [{foo:'foo'}, 'bar'],
      [{foo:true}, false]
    ].map _.first _.property 'foo'

    expect(res).toEqual([10, 'foo', true])

describe 'last', ->
  it 'should map the given value at last index in the element', ->

    res = [
      [10, 20],
      ['foo', 'bar'],
      [true, false]
    ].map _.last()

    expect(res).toEqual([20, 'bar', false])

  it 'should apply the passed-in mapper to the last index', ->

    res = [
      [20, {foo:10}],
      ['bar', {foo:'foo'}],
      [false, {foo:true}]
    ].map _.last _.property 'foo'

    expect(res).toEqual([10, 'foo', true])

describe 'at', ->
  it 'should map the given value at index in the element', ->

    res = [
      [10, 20, 30],
      ['foo', 'bar', 'baz'],
      [true, false, undefined]
    ].map _.at 1

    expect(res).toEqual([20, 'bar', false])

  it 'should apply the passed-in mapper to the at index', ->

    res = [
      [20, {foo:10}, 30],
      ['bar', {foo:'foo'}, 'baz'],
      [false, {foo:true}, undefined]
    ].map _.at 1, _.property 'foo'

    expect(res).toEqual([10, 'foo', true])

describe 'length', ->
  it 'should map the length of the element', ->

    res = [
      'foo',
      [10,20],
      {foo: 'bar'}
    ].map _.length()

    expect(res).toEqual([3,2,1])
