require '../../../test_helper'

describe 'Array::flatten', ->
  it 'should flatten all the sub arrays in the array', ->
    array = [[["foo"],"bar"],"baz"].flatten()

    expect(array).toEqual(['foo','bar','baz'])

  it 'should flatten the arrays until the specified level', ->

    array = [[["foo"],"bar"],"baz"].flatten(1)

    expect(array).toEqual([['foo'],'bar','baz'])

describe 'Array::step', ->
  it 'should iterates over an array with the given step', ->

    array = ["foo","bar","baz"]

    n = 0
    tuples = []
    array.step 2, (a,b) ->
      n += 1
      tuples.push [a,b]

    expect(n).toBe(2)
    expect(tuples).toEqual([['foo','bar'],['baz',undefined]])

describe 'Array::group', ->
  it 'should groups elements in an array into sub-arrays', ->

    array = ['foo', 'bar', 'baz'].group(2)

    expect(array).toEqual([['foo','bar'],['baz']])

describe 'Array::reject', ->
  it 'should returns an array without the rejected values', ->

    array = ["foo", "bar", "baz"].reject (v) -> v in ["bar","baz"]

    expect(array.length).toBe(1)
    expect(array).toEqual(['foo'])

  it 'should returns the same array when called without filter', ->
    array = ["foo", "bar", "baz"].reject()

    expect(array.length).toBe(3)
    expect(array).toEqual(['foo','bar','baz'])

describe 'Array::select', ->
  it 'should returns an array with the selected values', ->
    array = ["foo", "bar", "baz"].select (v) -> v in ["bar","baz"]

    expect(array.length).toBe(2)
    expect(array).toEqual(['bar','baz'])

  it 'should returns an empty array when called without filter', ->
    array = ["foo", "bar", "baz"].select()

    expect(array.length).toBe(0)

describe 'Array::last', ->
  it 'should returns the last element in the array', ->
    last = ['foo', 'bar', 'baz'].last()

    expect(last).toBe('baz')

  it 'should returns undefined when the array is empty', ->
    last = [].last()

    expect(last).toBeUndefined()

describe 'Array::first', ->
  it 'should returns the first element in the array', ->
    first = ['foo', 'bar', 'baz'].first()

    expect(first).toBe('foo')

  it 'should returns undefined when the array is empty', ->
    first = [].first()

    expect(first).toBeUndefined()

describe 'Array::rotate', ->
  it 'should returns an array rotated by one when called without arguments', ->
    array = ['foo', 'bar', 'baz'].rotate()

    expect(array).toEqual(['bar','baz','foo'])

  it 'should returns an array rotated by two', ->
    array = ['foo', 'bar', 'baz'].rotate 2

    expect(array).toEqual(['baz','foo','bar'])

  it 'should returns an array rotated in the inverse sens by two', ->
    array = ['foo', 'bar', 'baz'].rotate -2

    expect(array).toEqual(['bar','baz','foo'])

  it 'should leave the original array unchanged', ->

    array = ['foo', 'bar', 'baz']
    array.rotate 2

    expect(array).toEqual(['foo','bar','baz'])

describe 'Array::uniq', ->
  it 'should removes all duplicates in the current array', ->
    array = ['foo','bar','foo','baz','bar'].uniq()

    expect(array).toEqual(['foo','bar','baz'])

describe 'Array::min', ->
  it 'should returns the minimal value in the array', ->
    min = [5, 2, 3, 8].min()

    expect(min).toBe(2)

describe 'Array::max', ->
  it 'should returns the maximal value in the array', ->
    max = [5, 2, 3, 8].max()

    expect(max).toBe(8)

describe 'Array::compact', ->
  it 'should remove the undefined elements from an array', ->
    a = ['foo', 10, null, false, undefined]

    expect(a.compact()).toEqual(['foo', 10, false])
