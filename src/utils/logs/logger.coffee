#@toc

Signal = require '../../core/signal'

## Logger

# The `Logger` class handle logging within the Neat environment.
# Whenever you use one of the logging functions, it ultimately
# end up here.
class Logger

  # The `Logger` class provides some *constants* to define
  # the priority of a log message.
  #
  # That priority is used to filter messages according to
  # a given configuration verbosity.
  @DEBUG = 0
  @INFO = 1
  @WARN = 2
  @ERROR = 3
  @FATAL = 4

  ##### Logger::constructor

  # The `Logger` class provides a `logged` signal that backends
  # can register to.
  #
  # The `stack` property is used to store the messages received
  # before a backend had been registered.
  constructor: ->
    @logged = new Signal
    @stack = []

  ##### Logger::log

  # Register a `message` with the given level.
  # If the logger instance has a backend registered, the message
  # is automatically dispatched. Otherwise, the message is stored.
  log: (message, level=0) ->
    o = {message, level}
    if @logged.hasListeners()
      @logged.dispatch this, o
    else
      # In order to prevent the stack to became too wide,
      # messages with the same level of priority are
      # concateneted.
      if @stack.empty() or @stack.last().level isnt level
        @stack.push o
      else
        @stack.last().message += message

  ##### Logger::add

  # Add a function to listen to the `logged` signal.
  # Use this function rather than `logged.add`. This
  # function will take care of dispatching the stack
  # to the listeners when a listener is added.
  add: (listener, context=null, priority=0) ->
    @logged.add listener, context, priority
    @logged.dispatch this, log for log in @stack if @logged.hasListeners()

  ##### Logger::remove

  # Removes a function for listening to the `logged` signal.
  remove: (listener, context) ->
    @logged.remove listener, context

module.exports = Logger
