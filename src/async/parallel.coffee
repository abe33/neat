# The `Parallel` class allow to run an array of commands
# in parallel and will call back once all the commands
# have call back.
#
#     foo = (callback) ->
#       console.log 'foo'
#       setTimeout callback, 150
#
#     bar = (callback) ->
#       console.log 'bar'
#       setTimeout callback, 100
#
#     parallel = new Parallel(foo, bar)
#     parallel.run ->
#       console.log 'parallel completed'
#
#     # 'foo'
#     # 'bar'
#     # 'parallel completed'
class Parallel
 # Constructs the parallel with the passed-in commands.
  # You can either pass a list of commands which can
  # either contains arrays of commands.
  constructor: (commands...) ->
    @commands = commands.flatten()

  # Starts the parallel process. The `callback` arguments will
  # be called at the end of the whole parallel process.
  run: (callback) ->
    @counter = 0
    # Each command in the object will be called with the same
    # callback. This callback will wait until all the commands
    # have ended before calling the `Parallel` callback.
    f = =>
      @counter += 1
      callback?() if @counter is @commands.length

    # All the commands are trigerred at once.
    command f for command in @commands

module.exports = Parallel
