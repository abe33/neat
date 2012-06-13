{Module, Mixin} = require '../../../lib/core'

describe Mixin, ->
  it 'should allow to create mixins', ->

    TestMixin = Mixin
      foo: "bar"
      bar: "foo"

    class MockModule extends Module
      @include TestMixin

    instance = new MockModule

    expect(instance.foo).toBe("bar")
    expect(instance.bar).toBe("foo")

  it 'should provide a way to test if an object has included the mixin', ->

    TestMixin = Mixin
      foo: "bar"
      bar: "foo"

    class MockModuleA extends Module
      @include TestMixin

    class MockModuleB extends Module
      @include TestMixin

    class MockModuleC extends MockModuleB

    instanceA = new MockModuleA
    instanceB = new MockModuleB
    instanceC = new MockModuleC
    object = {}

    expect(TestMixin.isMixinOf instanceA).toBeTruthy()
    expect(TestMixin.isMixinOf instanceB).toBeTruthy()
    expect(TestMixin.isMixinOf instanceC).toBeTruthy()
    expect(TestMixin.isMixinOf object).toBeFalsy()

