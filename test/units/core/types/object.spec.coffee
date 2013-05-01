require '../../../test_helper'
{Module, Mixin} = require '../../../../lib/core'

describe 'Object::merge', ->
  it 'should merge the passed-in object in the current one', ->

    target = foo:"irrelevant"
    target.merge bar:"irrelevant"

    expect(target.bar).toBe("irrelevant")

describe 'Object::sort', ->
  it 'should return a new Object whose properties have been sorted', ->
    source = foo: 1, bar: 2, baz: 3
    target = source.sort()
    expectedKeys = ['bar', 'baz', 'foo']
    expectedValues = [2, 3, 1]
    count = 0
    expect(target).toBeDefined()
    for k,v of target
      expect(k).toBe(expectedKeys[count])
      expect(v).toBe(expectedValues[count])
      count++

describe 'Object::keys', ->
  it 'should returns an array containing the keys', ->

    target = foo:'irrelevant', bar:'irrelevant', baz:'irrelevant'

    keys = target.keys()

    expect(keys).toEqual(['foo','bar','baz'])

  it 'should returns an array with the keys added dynamically', ->

    target = {}
    target.foo = "irrelevant"
    target.bar = "irrelevant"
    target.baz = "irrelevant"

    keys = target.keys()

    expect(keys).toEqual(['foo','bar','baz'])

describe 'Object::sortedKeys', ->
  it 'should returns an array containing the keys sorted alphabetically', ->

    target = foo:'irrelevant', bar:'irrelevant', baz:'irrelevant'

    keys = target.sortedKeys()

    expect(keys).toEqual(['bar','baz','foo'])

describe 'Object::size', ->
  it 'shound return the number of enumerable properties of an object', ->

    expect({}.size()).toBe(0)
    expect({foo:"irrelevant"}.size()).toBe(1)
    expect({foo:"irrelevant",bar:"irrelevant"}.size()).toBe(2)

describe 'Object::length', ->
  it 'shound return the number of enumerable properties of an object', ->

    expect({}.length()).toBe(0)
    expect({foo:"irrelevant"}.length()).toBe(1)
    expect({foo:"irrelevant",bar:"irrelevant"}.length()).toBe(2)

describe 'Object::reject', ->
  it 'should return an object without the rejected properties', ->

    target = foo: "irrelevant", bar: "irrelevant", baz: "irrelevant"

    filtered = target.reject (k,v) -> k in ["bar", "baz"]

    expect(filtered.foo).toBe("irrelevant")
    expect(filtered.bar).toBeUndefined()
    expect(filtered.baz).toBeUndefined()

  it 'should return the same object when called without a filter', ->
    target = foo: "irrelevant", bar: "irrelevant", baz: "irrelevant"

    filtered = target.reject()

    expect(filtered.foo).toBe("irrelevant")
    expect(filtered.bar).toBe("irrelevant")
    expect(filtered.baz).toBe("irrelevant")

describe 'Object::select', ->
  it 'should return an object without the selected properties', ->

    target = foo: "irrelevant", bar: "irrelevant", baz: "irrelevant"

    filtered = target.select (k,v) -> k in ["bar", "baz"]

    expect(filtered.foo).toBeUndefined()
    expect(filtered.bar).toBe("irrelevant")
    expect(filtered.baz).toBe("irrelevant")

  it 'should returns an empty object when called without a filter', ->

    target = foo: "irrelevant", bar: "irrelevant", baz: "irrelevant"

    filtered = target.select()

    expect(filtered.foo).toBeUndefined()
    expect(filtered.bar).toBeUndefined()
    expect(filtered.baz).toBeUndefined()


describe 'Object::values', ->
  it 'should returns an array containing the values
      of the object properties'.squeeze(), ->

    target = foo: "FOO", bar: "BAR", baz: "BAZ"

    values = target.values()

    expect(values.length).toBe(3)
    expect(values).toEqual(['FOO','BAR','BAZ'])

describe 'Object::sortedValues', ->
  it 'should returns an array containing the values
      of the object properties'.squeeze(), ->

    target = foo: "FOO", bar: "BAR", baz: "BAZ"

    values = target.sortedValues()

    expect(values.length).toBe(3)
    expect(values).toEqual(['BAR','BAZ','FOO'])

describe 'Object::hasKey', ->
  it 'should returns true for properties set on an object', ->

    target = foo: "irrelevant"
    target.bar = "irrelevant"
    target.merge baz: "irrelevant"

    expect(target.hasKey "foo").toBeTruthy()
    expect(target.hasKey "bar").toBeTruthy()
    expect(target.hasKey "baz").toBeTruthy()

  it 'should returns true for properties inherited from its prototype', ->

    target = {}

    expect(target.hasKey 'merge').toBeTruthy()
    expect(target.hasKey 'length').toBeTruthy()
    expect(target.hasKey 'size').toBeTruthy()

  it 'should returns false for properties not set on an object', ->

    target = {}

    expect(target.hasKey 'foo').toBeFalsy()
    expect(target.hasKey 'bar').toBeFalsy()
    expect(target.hasKey 'baz').toBeFalsy()

describe 'Object::has', ->
  it 'should return true for items stored in the object', ->

    target = foo: 'bar', bar: 'baz'

    expect(target.has 'bar').toBeTruthy()
    expect(target.has 'baz').toBeTruthy()

  it 'should return false for items not stored in the object', ->

    target = foo: 'bar', bar: 'baz'

    expect(target.has 'foo').toBeFalsy()

describe 'Object::flatten', ->
  it 'should returns an array with keys and values alternatively', ->
    source = foo: 10, bar: 20, baz: 30
    target = source.flatten()

    expect(target).toEqual(['foo', 10, 'bar', 20, 'baz', 30])

describe 'Object.new', ->
  it 'should creates an object with an array as source', ->

    target = Object.new ['foo','irrelevant','bar','irrelevant']

    expect(target.foo).toBe('irrelevant')
    expect(target.bar).toBe('irrelevant')

describe 'Object::concat', ->
  it 'should return a new object that is a copy of the original
      one when called without arguments'.squeeze(), ->

    original =
      foo: "bar"
      bar: "foo"

    copy = original.concat()

    expect(copy).not.toBe(original)
    expect(copy).toEqual(original)

  it 'should merge the passed-in arguments within the created object', ->

    original =
      foo: "bar"
      bar: "foo"

    copy = original.concat baz: 'baz'

    expect(copy).not.toBe(original)
    expect(copy).not.toEqual(original)
    expect(copy).toEqual(foo: "bar", bar: 'foo', baz: 'baz')

describe 'Object::empty', ->
  it 'should return true for an empty object', ->
    expect({}.empty()).toBeTruthy()

  it 'should return false for an object with properties', ->
    expect({foo: 10}.empty()).toBeFalsy()

describe 'Object::first', ->
  it 'should return a tuple containing the first key:value', ->
    o =
      foo: 10
      bar: 20

    expect(o.first()).toEqual(['foo',10])

  it 'should return null if the object is empty', ->
    expect({}.first()).toBeNull()

describe 'Object::last', ->
  it 'should return a tuple containing the last key:value', ->
    o =
      foo: 10
      bar: 20

    expect(o.last()).toEqual(['bar',20])

  it 'should return null if the object is empty', ->
    expect({}.last()).toBeNull()

describe 'Object::map', ->
  it 'should map the properties of an object to another object
      with the mapping function provided', ->

    source =
      foo: 10
      bar: "foo"

    result = source.map (k,v) -> ["_#{k}_", v]

    expect(result).toEqual(_foo_: 10, _bar_: "foo")

describe 'Object::each', ->
  it 'should iterate over the object properties', ->
    a = []
    source =
      foo: 10
      bar: 20

    source.each (k,v) -> a.push k

    expect(a).toEqual(['foo', 'bar'])

describe 'Object::destroy', ->
  it 'should delete an existing property and return its previous value', ->
    source =
      foo: 10
      bar: 20

    res = source.destroy 'foo'

    expect(source.foo).toBeUndefined()
    expect(res).toBe(10)

  it 'should return null if there is no property to delete', ->
    source = {}
    res = source.destroy 'foo'

    expect(res).toBeNull()

describe 'Object::tap', ->
  it 'should call the passed-in block with the current object', ->
    source = {}
    tapped = source.tap (o) ->
      o.foo = 'bar'

    expect(source).toBe(tapped)
    expect(source.foo).toBe('bar')
