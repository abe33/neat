# Mappers are functions that extract or perform transformations on data
# when used in combination with the `Array::map` function.
#
#@toc
#
# A mapper is a function that takes the element to map as argument.
# The function is generated through currying.
#
#     mapper = (setup) -> (el) ->
#       # do something with el according to setup

##### at

# Returns the value at the specified index in the element.
#
#     a = [
#       [0,1,2,3,4],
#       [5,6,7,8,9]
#     ].map at 2
#     # [2, 7]
#
# Optionally the `at` mapper accept another mapper as argument.
# This mapper will be used against the value extracted from the element.
#
#     a = [
#       [0,1,2,3,4],
#       [5,6,7,8,9]
#     ].map at 2, (el) -> el * 2
#     # [4, 14]
at = (index=0, mapper) -> (el) ->
  return undefined unless el?
  if mapper? then mapper el[index] else el[index]

##### first

# Returns the first value in the element.
#
#     a = [
#       [0,1,2,3,4],
#       [5,6,7,8,9]
#     ].map first()
#     # [0, 5]
#
# Optionally the `first` mapper accept another mapper as argument.
# This mapper will be used against the value extracted from the element.
#
#     a = [
#       [0,1,2,3,4],
#       [5,6,7,8,9]
#     ].map first (el) -> el * 2
#     # [0, 10]
first = (mapper) -> (el) ->
  return undefined unless el?
  if mapper? then mapper el.first?() else el.first?()

##### last

# Returns the last value in the element.
#
#     a = [
#       [0,1,2,3,4],
#       [5,6,7,8,9]
#     ].map last()
#     # [4, 9]
#
# Optionally the `last` mapper accept another mapper as argument.
# This mapper will be used against the value extracted from the element.
#
#     a = [
#       [0,1,2,3,4],
#       [5,6,7,8,9]
#     ].map last (el) -> el * 2
#     # [8, 18]
last = (mapper) -> (el) ->
  return undefined unless el?
  if mapper? then mapper el.last?() else el.last?()

##### length

# Returns the length of the element if this element provides either
# a property or a function named `length`.
#
#     a = ['foo', ['bar', 'world'], {foo: 0}].map length()
#     # [3, 2, 1]
length = -> (el) ->
  return undefined unless el?
  if typeof el.length is 'function' then el.length() else el.length

##### property

# Returns the value of the property named `key` of the element.
#
#     a = [
#       {foo: 10},
#       {foo: 'bar'},
#       {foo: false},
#     ].map property 'foo'
#     # [10, 'bar', false]
#
# Optionally the `property` mapper accept another mapper that will
# be used to map the value of the element's property.
#
#     a = [
#       {foo: 10},
#       {foo: 'bar'},
#       {foo: false},
#     ].map property 'foo', (el) -> typeof el
#     # ['number', 'string', 'boolean']
property = (key, mapper) -> (el) ->
  return undefined unless el?
  if mapper? then mapper el[key] else el[key]

module.exports = {
  at,
  first,
  last,
  length,
  property,
}
