# Use a `Signal` object wherever you need to dispatch an event.
# A `Signal` is a dispatcher that have only one channel.
#
# Signals are generally defined as property of an object. And
# their name generally end with a past tense verb, such as in:
#
#     myObject.somethingChanged
class Signal

  # Signals maintain an array of listeners.
  constructor: ->
    @listeners = []

  #### Listeners management
  #
  # Listeners are stored internally as an array with the form:
  #
  #     [listener, context, calledOnce, priority]

  # You can register a listener with or without a context.
  # The context is the object that can be accessed through `this`
  # inside the listener function body.
  #
  # An optional `priority` argument allow you to force
  # an order of dispatch for a listener.
  add: (listener, context, priority = 0) ->

    # A listener can be registered several times, but only
    # if the context object is different each time.
    #
    # In other words, the following is possible:
    #
    #     listener = ->
    #     context = {}
    #     myObject.signal.add listener
    #     myObject.signal.add listener, context
    #
    # When the following is not:
    #
    #     listener = ->
    #     myObject.signal.add listener
    #     myObject.signal.add listener
    if not @registered listener, context
      @listeners.push [listener, context, false, priority]

      # Listeners are sorted according to their order each time
      # a new listener is added.
      @sortListeners()

  # Listeners can be registered for only one call.
  #
  # All the others rules are the same. So you can't add
  # the same listener/context couple twice through the two methods.
  addOnce: (listener, context, priority = 0) ->
    if not @registered listener, context
      @listeners.push [listener, context, true, priority]
      @sortListeners()

  # Listeners can be removed, but only with the context with which
  # they was added to the signal.
  #
  # In this regards, avoid to register listeners without a context.
  # If later in the application a context is forgotten or invalid
  # when removing a listener from this signal, the listener
  # without context will end up being removed.
  remove: (listener, context) ->
    if @registered listener, context
      @listeners.splice @indexOf(listener, context), 1

  # All listeners can be removed at once if needed.
  removeAll: ->
    @listeners = []

  # `indexOf` returns the position of the listener/context couple
  # in the listeners array.
  indexOf: (listener, context) ->
    return i for [l,c],i in @listeners when listener is l and context is c
    -1

  # Use the `registered` method to test whether a listener/context couple
  # have been registered in this signal.
  registered: (listener, context) ->
    @indexOf(listener, context) isnt -1

  # The listeners are sorted according to their `priority`.
  # The higher the priority the lower the listener will be
  # in the call order.
  sortListeners: ->
    return if @listeners.length <= 1
    @listeners.sort (a, b) ->
      [pA, pB ] = [ a[3], b[3]]

      if pA < pB then 1 else if pB < pA then -1 else 0

  #### Dispatch

  # Signals are dispatched to all the listeners. All the arguments
  # passed to the dispatch become the signal's message.
  #
  # Listeners registered for only one call will be removed after
  # the call.
  dispatch: ->
    listeners = @listeners.concat()
    for [listener, context, once, priority] in listeners
      listener.apply context, arguments
      @remove listener, context if once

module.exports = Signal
