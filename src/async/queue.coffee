# The `Queue` class allow to run an array of commands
# one after the other. A command is simply a function
# that takes a callback function as only argument.
#
#     foo = (callback) ->
#       console.log 'foo'
#       setTimeout callback, 100
#
#     bar = (callback) ->
#       console.log 'bar'
#       setTimeout callback, 150
#
#     queue = new Queue(foo, bar)
#     queue.run ->
#       console.log 'queue completed'
#
#     # 'foo'
#     # 'bar'
#     # 'queue completed'
#
# **Note:** The queue calls the next command in the callback
# of the previous command, it can lead the call stack to grow
# excessively and you may encounter `RangeError: Maximum call
# stack size exceeded` (this will most likely occurs if you're
# using nested queues, or queues of heavy asynchronous processes).
# In such case, there's two way to work around:
#
#  1. Some (or all) of the commands you're trying to run can
#     be run concurrently (doing stuff to a bunch of files
#     for instance). Then you should probably consider using
#     the `Parallel` batch object instead for these commands.
#  2. All of the commands need to be performed one after the
#     other. In that case, you may reconsider your approach
#     on the whole processus you're trying to perform and how
#     you should approach it (Don't consider the `--max-stack-size`
#     as a good way to solve your issue).
class Queue
  # Constructs the queue with the passed-in commands.
  # You can either pass a list of commands which can
  # either contains arrays of commands.
  constructor: (commands...) ->
    @commands = commands.flatten()

  # Starts the queue process. The `callback` arguments will
  # be called at the end of the whole queue process.
  run: (callback) ->
    @iterator = 0
    # While there's still a command to process.
    if @iterator < @commands.length
      # The command is executed with a callback that'll
      # let the queue continue.
      @commands[@iterator] => @run callback
      @iterator += 1
    else callback?()

module.exports = Queue
