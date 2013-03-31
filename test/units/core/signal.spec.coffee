require '../../test_helper'
{Signal} = require '../../../lib/core'

describe 'Signal', ->
  it 'should have listeners', ->
    signal = new Signal
    listener = ->

    signal.add listener

    expect(signal.listeners.length).toBe(1)

  it 'should dispatch message to its listeners', ->
    message = null
    signal = new Signal
    listener = ->
      message = arguments[0]

    signal.add listener
    signal.dispatch "hello"

    expect(message).toBe("hello")

  it 'shouldn\'t add the same listener twice', ->
    signal = new Signal
    listener = ->

    signal.add listener
    signal.add listener

    expect(signal.listeners.length).toBe(1)

  it 'should allow to remove listeners', ->
    signal = new Signal
    listener = ->

    signal.add listener
    signal.remove listener

    expect(signal.listeners.length).toBe(0)

  it 'should allow to register a listener with a context', ->
    signal = new Signal
    context = {}
    listenerScope = null
    listener = ->
      listenerScope = this

    signal.add listener, context
    signal.dispatch "hello"

    expect(listenerScope).toBe(context)

  it 'should allow to register a same listener twice
      with different context'.squeeze(), ->

    signal = new Signal
    context1 = {}
    context2 = {}
    listener = ->

    signal.add listener, context1
    signal.add listener, context2

    expect(signal.listeners.length).toBe(2)

  it 'should allow to remove a listener bind with a context', ->
    signal = new Signal
    context1 = foo: "Foo"
    context2 = foo: "Bar"
    lastCall = null
    listener = ->
      lastCall = this.foo

    signal.add listener, context1
    signal.add listener, context2

    signal.remove listener, context1

    signal.dispatch()

    expect(signal.listeners.length).toBe(1)
    expect(lastCall).toBe("Bar")

  it 'should allow to register a listener for a single call', ->
    signal = new Signal
    callCount = 0
    listener = ->
      callCount++

    signal.addOnce listener

    signal.dispatch()
    signal.dispatch()

    expect(callCount).toBe(1)

  it 'should be able to priorize listeners', ->
    signal = new Signal
    listenersCalls = []

    listener1 = ->
      listenersCalls.push "listener1"

    listener2 = ->
      listenersCalls.push "listener2"

    signal.add listener1
    signal.add listener2, null, 1

    signal.dispatch()

    expect(listenersCalls).toEqual(["listener2", "listener1"])

  it 'should allow listeners registered for a single
      call to have a priority'.squeeze(), ->
    signal = new Signal
    listenersCalls = []

    listener1 = ->
      listenersCalls.push "listener1"

    listener2 = ->
      listenersCalls.push "listener2"

    signal.add listener1
    signal.addOnce listener2, null, 1

    signal.dispatch()

    expect(listenersCalls).toEqual(["listener2", "listener1"])

  it 'should be able to remove all listeners at once', ->
    signal = new Signal

    listener1 = ->
    listener2 = ->

    signal.add listener1
    signal.add listener2

    signal.removeAll()
    expect(signal.listeners.length).toBe(0)

  it 'should be able to tell when listeners are registered', ->

    signal = new Signal

    expect(signal.hasListeners()).toBeFalsy()

    listener = ->

    signal.add listener

    expect(signal.hasListeners()).toBeTruthy()

  describe 'with an asynchronous listener', ->

    it 'should wait until the callback was called
        before going to the next listener'.squeeze(), ->

      listener1Called = false
      listener1Args = null
      listener2Args = null
      ended = false

      listener1 = (a,b,c,callback) ->
        setTimeout ->
          listener1Args = [a,b,c]
          listener1Called = true
          callback?()
        , 100

      listener2 = (a,b,c) ->
        listener2Args = [a,b,c]
        expect(listener1Called).toBeTruthy()
        expect(listener1Args).toEqual(listener2Args)
        ended = true

      signal = new Signal

      signal.add listener1
      signal.add listener2

      runs ->
        signal.dispatch(1,2,3)

      waitsFor progress(-> ended), 'Signal timed out', 1000

    it 'should call back the passed-in function
        at the end of the dispatch'.squeeze(), ->

      ended = false
      listener1 = (a, b, c, callback) -> setTimeout callback, 120
      listener2 = (a, b, c, callback) -> setTimeout callback, 120

      signal = new Signal

      signal.add listener1
      signal.add listener2
      ms = new Date().valueOf()

      runs ->
        signal.dispatch 1, 2, 3, ->
          ended = true

      waitsFor progress(-> ended), 'Signal timed out', 1000

  describe 'when a listener signature have been specified', ->
    it 'should prevent invalid listener to be passed', ->

      signal = new Signal 'a', 'b'

      expect(-> signal.add ->).toThrow()
      expect(-> signal.addOnce ->).toThrow()

      expect(-> signal.add (a, b) ->).not.toThrow()
      expect(-> signal.add (a, b, callback) ->).not.toThrow()


