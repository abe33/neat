# This file contains a set of matchers that can be used in various situations
# such as array filters or duck tests.
#
# Matchers are curried functions that generates testing functions based
# on the arguments passed to the generator.
#
#     testFunction = equalTo 10
#     testFunction 10 # true
#
# @toc

##### match

# The match function either call `m` with `v` when `m` is a function
# or compare `m` and `v` otherwise.
#
# Match is used whenever a matcher function allow matchers as arguments.
match = (m,v) -> if typeof m is 'function' then m v else m is v

##### anyOf

# Returns `true` if any of the `matchers` match `el`.
#
#     ary = ['foo', 10, false]
#     ary.some anyOf 10, isType('string') # true
anyOf = (matchers...) -> (el) ->
  return true for m in matchers when match m, el
  false

##### allOf

# Returns `true` if all of the `matchers` match `el`.
#
#     ary = ['foo', 10, false]
#     ary.some allOf 10, isType('string') # false
allOf = (matchers...) -> (el) ->
  return false for m in matchers when not match m, el
  true

##### equalTo

# Compares `el` with `val` using the `===` operator.
#
#     ary = ['foo', 10, false]
#     ary.some equalTo 'foo' # true
equalTo = (val) -> (el) -> el is val

##### greaterThan

# Returns `true` when `el` is greater than `val`.
#
#     ary = ['foo', 10, false]
#     ary.some greaterThan 5 # true
greaterThan = (val) -> (el) -> el > val

##### greaterThanOrEqualTo

# Returns `true` when `el` is greater than or equal to `val`.
#
#     ary = ['foo', 10, false]
#     ary.some greaterThanOrEqualTo 10 # true
greaterThanOrEqualTo = (val) -> (el) -> el >= val

##### hasProperty

# The `hasProperty` allow to both test the existence of a property
# and test the content of the property.
#
#     obj = foo: 10
#     hasProperty('foo')(obj)                  # true
#     hasProperty('foo', 10)(obj)              # true
#     hasProperty('foo', isType 'number')(obj) # true
hasProperty = (prop, val) -> (el) ->
  el[prop] isnt undefined and if val? then match val, el[prop] else true

##### hasProperties

# The `hasProperty` allow to both test the existence of properties
# and test the content of these properties.
#
# You can path both string and objects as arguments, whatever order.
# A string will only test for the existence of the property and an
# object will test for each property defined in the object, the values
# of the argument properties being the matchers to use against the tested
# objet properties.
#
#     obj = foo: 10, bar: false
#
#     hasProperties('foo', 'bar')(obj)                   # true
#     hasProperties(foo: 10, bar: isType 'boolean')(obj) # true
#     hasProperties('foo', bar: false)(obj)              # true
hasProperties = (propsets...) -> (el) ->

  results = true
  for propset in propsets
    if typeof propset is 'string'
      results &&= el[propset] isnt undefined
    else
      for k,v of propset
        results &&= hasProperty(k,v)(el)
  results

##### isNot

# Inverse the boolean value returned by a matcher, or test the difference
# with `m` if it's not a function.
#
#     ary = ['foo', 10, false]
#     ary.some isNot equalTo 'foo' # true
isNot = (m) -> (el) -> not match m, el

##### isNotNull

# Returns `true` if `el` is not null.
isNotNull = -> (el) -> el?

##### isNull

# Returns `true` if `el` is null.
isNull = -> (el) -> not el?

##### isType

# Returns `true` if the product of `typeof el` is equal
# to `type`.
#
#     ['foo'].every isType 'string' # true
isType = (type) -> (el) -> typeof el is type

##### lowerThan

# Returns `true` when `el` is lower than `val`.
#
#     ary = ['foo', 10, false]
#     ary.some lowerThan 15 # true
lowerThan = (val) -> (el) -> el < val

##### lowerThanOrEqualTo

# Returns `true` when `el` is lower than or equal to `val`.
#
#     ary = ['foo', 10, false]
#     ary.some lowerThanOrEqualTo 10 # true
lowerThanOrEqualTo = (val) -> (el) -> el <= val

##### quacksLike

# Performs a duck test with `def` definition against `el`.
#
#     ary = [
#       {foo: 10, bar: 'baz'},
#       {},
#       {baz: 'bar'},
#     ]
#     def = __definition__:
#       foo: 'number'
#       bar: (v) -> v is 'baz'
#
#     ary.some quacksLike def # true
quacksLike = (def) -> (el) -> el?.quacksLike def

module.exports = {
  allOf,
  anyOf,
  equalTo,
  greaterThan,
  greaterThanOrEqualTo,
  hasProperties,
  hasProperty,
  isNot,
  isNotNull,
  isNull,
  isType,
  lowerThan,
  lowerThanOrEqualTo,
  quacksLike,
}
