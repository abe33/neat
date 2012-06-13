{Module, Mixin} = require '../../../lib/core'

describe 'Object::merge', ->
  it 'should merge the passed-in object in the current one', ->

    target = foo:"irrelevant"
    target.merge bar:"irrelevant"

    expect(target.bar).toBe("irrelevant")

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

describe 'Object::quacksLike', ->
  it 'should be able to tell when an object match the definition
      of a given mixin'.squeeze(), ->

    TestMixinA = Mixin
      foo: "bar"
      bar: "foo"
      method: -> "quack!"
      __definition__:
        foo: "string"
        bar: "*"
        method: "function"

    TestMixinB = Mixin
      foo: "bar"
      bar: "foo"

    TestMixinC = Mixin
      foo:"bar"
      bar:"foo"
      __definition__: (o) ->
        o.foo is "bar" and o.bar is "foo"

    class MockModuleA extends Module
      @include TestMixinA

    class MockModuleB extends Module
      @include TestMixinB

    class MockModuleC extends Module
      @include TestMixinA, TestMixinC

    class MockModuleD extends Module
      @include TestMixinB
      @__definition__:
        foo: "string"
        bar: "string"

    instanceA1 = new MockModuleA
    instanceA2 = new MockModuleA
    instanceA3 = new MockModuleA
    instanceA3.foo = 42
    instanceA4 = new MockModuleA
    instanceA4.method = 42
    instanceB = new MockModuleB
    instanceC1 = new MockModuleC
    instanceC2 = new MockModuleC
    instanceC2.foo = 42
    instanceD1 = new MockModuleD
    instanceD2 = new MockModuleD
    instanceD2.foo = 42
    object1 =
      foo: "bar"
      bar: "foo"
      method: -> "woof!"
    object2 = {}

    expect(instanceA1.quacksLike TestMixinA).toBeTruthy()
    expect(instanceA2.quacksLike TestMixinA).toBeTruthy()
    expect(instanceA3.quacksLike TestMixinA).toBeFalsy()
    expect(instanceA4.quacksLike TestMixinA).toBeFalsy()
    expect(instanceB.quacksLike TestMixinB).toBeFalsy()
    expect(instanceC1.quacksLike TestMixinA).toBeTruthy()
    expect(instanceC1.quacksLike TestMixinC).toBeTruthy()
    expect(instanceC2.quacksLike TestMixinA).toBeFalsy()
    expect(instanceC2.quacksLike TestMixinC).toBeFalsy()
    expect(instanceD1.quacksLike MockModuleD).toBeTruthy()
    expect(instanceD2.quacksLike MockModuleD).toBeFalsy()
    expect(object1.quacksLike TestMixinA).toBeTruthy()
    expect(object2.quacksLike TestMixinA).toBeFalsy()
