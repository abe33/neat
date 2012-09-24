# Use a `Signal` object wherever you need to dispatch an event.
# A `Signal` is a dispatcher that have only one channel.
# @toc

## Signal

# Signals are generally defined as property of an object. And
# their name generally end with a past tense verb, such as in:
#
#     myObject.somethingChanged = new Signal
class Signal

  ##### Signal::constructor

  # Optionally, a signal can have a specific signature.
  # A signature is a collection of argument names such:
  #
  #     positionChanged = new Signal 'target', 'position'
  #
  # If a signature is passed to a signal, every listener
  # added to the signal must then match the signature.
  #
  #     positionChanged.add (target, position) ->
  #       # will be registered
  #     positionChanged.add (target, position, callback) ->
  #       # will be registered too
  #     positionChanged.add () -> # will throw an error
  #
  # In the case of an asynchronous listener, the callback argument
  # is not considered as being part of the signature.
  constructor: (@signature...) ->
    @listeners = []
    # The `asyncListeners` property stores the number of asynchronous
    # listeners to use a synchronous dispatch when equal to 0.
    @asyncListeners = 0

  #### Listeners management
  #
  # Listeners are stored internally as an array with the form:
  #
  #     [listener, context, calledOnce, priority]

  ##### Signal::add

  # You can register a listener with or without a context.
  # The context is the object that can be accessed through `this`
  # inside the listener function body.
  #
  # An optional `priority` argument allow you to force
  # an order of dispatch for a listener.
  #
  # Signals listeners can be asynchronous, in that case the last
  # argument of the listener must be named `callback`. An async
  # listener blocks the dispatch loop until the callback function
  # passed to the listener is triggered.
  #
  #     # sync listener
  #     signal.add (a, b, c) ->
  #
  #     # async listener
  #     signal.add (a, b, c, callback) -> callback()
  add: (listener, context, priority = 0) ->
    @validate listener

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
      @asyncListeners++ if @isAsync listener

      # Listeners are sorted according to their order each time
      # a new listener is added.
      @sortListeners()

  ##### Signal::addOnce

  # Listeners can be registered for only one call.
  #
  # All the others rules are the same. So you can't add
  # the same listener/context couple twice through the two methods.
  addOnce: (listener, context, priority = 0) ->
    @validate listener
    if not @registered listener, context
      @listeners.push [listener, context, true, priority]
      @asyncListeners++ if @isAsync listener
      @sortListeners()

  ##### Signal::remove

  # Listeners can be removed, but only with the context with which
  # they was added to the signal.
  #
  # In this regards, avoid to register listeners without a context.
  # If later in the application a context is forgotten or invalid
  # when removing a listener from this signal, the listener
  # without context will end up being removed.
  remove: (listener, context) ->
    if @registered listener, context
      @asyncListeners-- if @isAsync listener
      @listeners.splice @indexOf(listener, context), 1

  ##### Signal::removeAll

  # All listeners can be removed at once if needed.
  #
  #     signal.removeAll()
  removeAll: ->
    @listeners = []
    @asyncListeners = 0

  ##### Signal::indexOf

  # `indexOf` returns the position of the listener/context couple
  # in the listeners array.
  indexOf: (listener, context) ->
    return i for [l,c],i in @listeners when listener is l and context is c
    -1

  ##### Signal::registered

  # Use the `registered` method to test whether a listener/context couple
  # have been registered in this signal.
  registered: (listener, context) ->
    @indexOf(listener, context) isnt -1

  ##### Signal::hasListeners

  # Returns true if the signal has listeners.
  hasListeners: -> @listeners.length isnt 0

  ##### Signal::sortListeners

  # The listeners are sorted according to their `priority`.
  # The higher the priority the lower the listener will be
  # in the call order.
  sortListeners: ->
    return if @listeners.length <= 1
    @listeners.sort (a, b) ->
      [pA, pB ] = [ a[3], b[3]]

      if pA < pB then 1 else if pB < pA then -1 else 0

  ##### Signal::validate

  # Throws an error if the passed-in listener's signature
  # doesn't match the signal's one.
  #
  #     signal = new Signal 'a', 'b', 'c'
  #     signal.validate () -> # false
  #     signal.validate (a,b,c) -> # true
  #     signal.validate (a,b,c,callback) -> # true
  validate: (listener) ->
    if @signature.length > 0
      re = /[^(]+\(([^)]+)\).*$/m
      listenerSignature = Function::toString.call(listener).split('\n').shift()
      signature = listenerSignature.replace(re, '$1')
      args = signature.split /\s*,\s*/g

      args.shift() if args.first() is ''
      args.pop() if args.last() is 'callback'

      s1 = @signature.join()
      s2 = args.join()

      m = "The listener #{listener} doesn't match the signal's signature #{s1}"
      throw new Error m if s2 isnt s1

  ##### Signal::isAsync

  # Returns `true` if the passed-in `listener` is asynchronous.
  #
  #     signal.isAsync -> # false
  #     signal.isAsync (callback) -> # true
  isAsync: (listener) ->
    Function::toString.call(listener).indexOf('callback)') != -1

  #### Signal Dispatch

  ##### Signal::dispatch

  # Signals are dispatched to all the listeners. All the arguments
  # passed to the dispatch become the signal's message.
  #
  #     signal.dispatch this, true
  #
  # Listeners registered for only one call will be removed after
  # the call.
  #
  # Optionally you can pass a callback argument to the dispatch function.
  # In that case, the callback must be the last argument passed to the
  # `dispatch` function.  This function will be called at the end
  # of the dispatch, allowing to execute code after all listeners,
  # even asynchronous, have been triggered.
  #
  #     signal.dispatch this, true, ->
  #       # all listeners have finish their execution
  #
  # **Note:** As the dispatch function will automatically consider
  # the last argument as the callback if its type is `function`, you should
  # avoid using function as the sole argument or as the last argument
  # for a listener. If that case occurs, consider either re-arranging the
  # arguments order or using a value object to carry the function.
  dispatch: (args..., callback)->
    unless typeof callback is 'function'
      args.push callback
      callback = null

    listeners = @listeners.concat()
    # If at leat one listener is async, the whole dispatch process is async
    # otherwise the fast route is used.
    if @asyncListeners > 0
      next = (callback) =>
        if listeners.length
          [listener, context, once, priority] = listeners.shift()

          if @isAsync listener
            listener.apply context, args.concat =>
              @remove listener, context if once
              next callback
          else
            listener.apply context, args
            @remove listener, context if once
            next callback
        else
          callback?()

      next callback
    else
      # The fast route is just a loop over the listeners.
      # At that point, if your listener do async stuff, it will
      # not prevent the dispatching until it's done.
      for [listener, context, once, priority] in listeners
        listener.apply context, arguments
        @remove listener, context if once

      callback?()

module.exports = Signal
