require '../../test_helper'
{Module} = require '../../../lib/core'

describe Module, ->
  it 'should fill the class prototype with the corresponding content', ->
    methodWasCalled = false
    methodContext = null

    TestMixin =
      foo: "bar"
      method: ->
        methodWasCalled = true
        methodContext = this

    class MockModule extends Module
      @include TestMixin

    instance = new MockModule

    instance.method()

    expect(instance.foo).toBe("bar")
    expect(methodWasCalled).toBeTruthy()
    expect(methodContext).toBe(instance)

  it 'should provides a hook on instanciation for mixins', ->

    methodWasCalled = false
    methodContext = null

    TestMixin =
      constructorHook: ->
        methodWasCalled = true
        methodContext = this

    class MockModule extends Module
      @include TestMixin

    instance = new MockModule

    expect(methodWasCalled).toBeTruthy()
    expect(methodContext).toBe(instance)

  it 'should be able to call the super function they overrides', ->

    methodWasCalled = false
    methodContext = null

    TestMixin =
      method: ->
        @super "method"

    class MockModuleA extends Module
      method:->
        methodWasCalled = true
        methodContext = this

    class MockModuleB extends MockModuleA
      @include TestMixin

    instance = new MockModuleB

    instance.method()

    expect(methodWasCalled).toBeTruthy()
    expect(methodContext).toBe(instance)

  it 'should trigger hooks in children for parent mixins without having
      its own mixins affecting the parent'.squeeze(), ->

    hookACalls = 0
    hookBCalls = 0

    MixinA =
      constructorHook: ->
        hookACalls++

    MixinB =
      constructorHook: ->
        hookBCalls++

    class MockModuleA extends Module
      @include MixinA

    class MockModuleB extends MockModuleA
      @include MixinB

    new MockModuleA
    new MockModuleB

    expect(hookACalls).toBe(2)
    expect(hookBCalls).toBe(1)

  it 'should notify mixins of their inclusion in a class', ->

    methodWasCalled = false
    methodContext = null
    methodArgument = null

    TestMixin =
      included: (base) ->
        methodWasCalled = true
        methodContext = this
        methodArgument = base

    class MockModule extends Module
      @include TestMixin

    instance = new MockModule

    expect(methodWasCalled).toBeTruthy()
    expect(methodContext).toBe(TestMixin)
    expect(methodArgument).toBe(MockModule)

  it 'should exclude members of a mixin listed in the excluded
      property of the mixin'.squeeze(), ->

    TestMixin =
      foo:"bar"
      bar:"foo"
      excluded:["bar"]

    class MockModule extends Module
      @include TestMixin

    instance = new MockModule

    expect(instance.bar).toBeUndefined()
    expect(instance.excluded).toBeUndefined()
