# This file contains Number's extensions that mimics some of the ruby
# Number methods.
# @toc

##### Number::ago

Number::ago = -> new Date new Date().getTime() - @valueOf()

##### Number::days

# Returns the current number as days converted in milliseconds.
Number::days = -> @hours() * 24

##### Number::even

# Returns `true` if the current number is even.
Number::even = -> @valueOf() % 2 is 0

##### Number::fromNow

# Returns a `Date` object that correspond to the time of the call
# plus the current number as milliseconds.
Number::fromNow = -> new Date new Date().getTime() + @valueOf()

##### Number::hours

# Returns the current number as hours converted in milliseconds.
Number::hours = -> @minutes() * 60

##### Number::later

# `Number::fromNow` alias.
Number.later = -> @fromNow()

##### Number::minutes

# Returns the current number as minutes converted in milliseconds.
Number::minutes = -> @seconds() * 60

##### Number::odd

# Returns `true` if the current number is odd.
Number::odd = -> @valueOf() % 2 is 1

##### Number::seconds

# Returns the current number as seconds converted in milliseconds.
Number::seconds = -> @valueOf() * 1000

##### Number::times

# Iterates `n` times and call `callback` for each iteration where `n` is
# the current `Number` value.
#
#     5.times (i) -> print "#{i} " # 0 1 2 3 4
#
# You can also multiply objects:
#
#     5.times "*"                  # '*****'
#     5.times 10                   # 50
#     2.times ['foo', 1]           # ['foo', 1, 'foo', 1]
Number::times = (target) ->
  return (target i for i in [0..@valueOf()-1]) if typeof target is "function"
  o = target

  for i in [1..@valueOf()-1]
    if target.concat?
      o = o.concat target
    else
      o += target
  o

##### Number::to

# Iterates from the current value to the passed-in value.
#
#     5.to 10, (i) -> print "#{i} " # 5 6 7 8 9 10
Number::to = (end, callback) -> callback i for i in [@valueOf()..end]

##### Number::weeks

# Returns the current number as weeks converted in milliseconds.
Number::weeks = -> @days() * 7

