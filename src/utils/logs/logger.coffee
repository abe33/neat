class Logger
  constructor: ->
    @logged = new Signal
    @stack = []

  log: (message, level=0) ->
    o = {message, level}
    if @logged.hasListeners()
      @logged.dispatch this, o
    else
      if @stack.empty() or @stack.last().level isnt level
        @stack.push o
      else
        @stack.last().message += message

  add: (listener, context=null, priority=0) ->
    @logged.add listener, context, priority
    @logged.dispatch this, log for log in @stack if @logged.hasListeners()

  remove: (listener, context) ->
    @logged.remove listener, context

module.exports = Logger
