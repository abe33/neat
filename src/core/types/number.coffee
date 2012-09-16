# This file contains Number's extensions that mimics some of the ruby
# Number methods.
# @toc
{def} = require './utils'

## Number

##### Number::ago

# Returns a `Date` object that correspond to the time of the call
# minus the current number as milliseconds.
#
#     10.hours().ago()
def Number, ago: -> new Date new Date().getTime() - @valueOf()

##### Number::days

# Returns the current number as days converted in milliseconds.
#
#     10.days() # 864000000
def Number, days: -> @hours() * 24

##### Number::even

# Returns `true` if the current number is even.
#
#     4.even() # true
#     5.even() # false
def Number, even: -> @valueOf() % 2 is 0

##### Number::fromNow

# Returns a `Date` object that correspond to the time of the call
# plus the current number as milliseconds.
#
#     10.hours().fromNow()
def Number, fromNow: -> new Date new Date().getTime() + @valueOf()

##### Number::hours

# Returns the current number as hours converted in milliseconds.
#
#     10.hours() # 36000000
def Number, hours: -> @minutes() * 60

##### Number::later

# `Number::fromNow` alias.
Number.later = -> @fromNow()

##### Number::minutes

# Returns the current number as minutes converted in milliseconds.
#
#     10.minutes # 600000
def Number, minutes: -> @seconds() * 60

##### Number::odd

# Returns `true` if the current number is odd.
#
#     4.odd() # false
#     5.odd() # true
def Number, odd: -> @valueOf() % 2 is 1

##### Number::seconds

# Returns the current number as seconds converted in milliseconds.
#
#     6.seconds # 6000
def Number, seconds: -> @valueOf() * 1000

##### Number::times

# Iterates `n` times and call `callback` for each iteration where `n` is
# the current `Number` value.
#
#     5.times (i) -> print "#{i} " # 0 1 2 3 4
#
# You can also multiply objects:
#
#     5.times "*"        # '*****'
#     5.times 10         # 50
#     2.times ['foo', 1] # ['foo', 1, 'foo', 1]
def Number, times: (target) ->
  return (target i for i in [0..@valueOf()-1]) if typeof target is "function"
  o = target

  for i in [1..@valueOf()-1]
    if Array.isArray o
      o = o.concat target
    else
      o += target
  o

##### Number::to

# Iterates from the current value to the passed-in value.
#
#     5.to 10, (i) -> print "#{i} " # 5 6 7 8 9 10
def Number, to: (end, callback) -> callback i for i in [@valueOf()..end]

##### Number::weeks

# Returns the current number as weeks converted in milliseconds.
#
#     1.week # 604800000
def Number, weeks: -> @days() * 7

