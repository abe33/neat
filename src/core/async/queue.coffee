# The `Queue` class allow to run an array of commands
# one after the other. A command is simply a function
# that takes a callback function as only argument.
class Queue
  # Constructs the queue with the passed-in commands.
  constructor: (@commands...) ->
    @commands = @commands.flatten()
    @iterator = 0

  # Starts the queue process.
  run: (callback) ->
    # While there's still a command to process.
    if @iterator < @commands.length
      # The command is executed with a callback that'll
      # let the queue continue.
      @commands[ @iterator ] => @run callback
      @iterator += 1
    else callback?()

module.exports = Queue
