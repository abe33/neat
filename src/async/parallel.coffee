class Parallel
  constructor: (commands...) ->
    @commands = commands.flatten()

  run: (callback) ->
    @counter = 0
    f = =>
      @counter += 1
      callback?() if @counter is @commands.length

    command f for command in @commands

module.exports = Parallel
