
{puts, yellow, inverse} = require './logs'

deprecated = (message) ->
  puts yellow("#{inverse ' DEPRECATED '} #{message}"), 5

module.exports = {deprecated}
