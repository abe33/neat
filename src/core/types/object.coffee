# This file contains Object's extensions that mimics some of the ruby
# Object and Hash methods.
# @toc

#### Helpers

# Defines a non-enumerable property on `Object.prototype`.
def = (o) ->
  for name,value of o
    unless Object.prototype[name]?
      Object.defineProperty? Object.prototype,
                             name,
                             enumerable: false, value: value

#### Class Extensions

##### Object.new

# Creates a new object from an array such as `[key, value, key, value, ...]`.
#
#     o = Object.new ['foo', 10, 'bar', 20, 'baz', 30]
#     # {foo: 10, bar: 20, baz: 30}
Object.new = (a) -> o = {}; a.step(2, (k,v) -> o[k] = v); return o

#### Instances Extensions

##### Object::contains

# `Object::has` alias.
def contains: (value) -> @has value

##### Object::flatten

# Returns an array such as `[key, value, key, value]` with the name
# and the content of the enumerable properties of this object.
#
#     {foo: 10, bar: 20, baz: 30}.flatten()
#     # ['foo', 10, 'bar', 20, 'baz', 30]
def flatten: -> a = []; a = a.concat [k,v] for k,v of this; return a

##### Object::has

# Retuns `true` if the specified values is contained in one of the object
# enumerable properties.
def has: (value) -> value in @values()

##### Object::hasKey

# Returns `true` if the specified key is defined on this object.
def hasKey: (key) -> @[key]?

##### Object::keys

# Returns an array of the keys enumerable on this object.
#
# The keys are returned as the `for..in` construct iterates on them.
# Use `sortedKeys` to retreive the keys sorted alphabetically.
def keys: -> k for k of this

##### Object::length

# Returns the count of enumerable properties on this object.
def length: -> @keys().length

##### Object::merge

# Merge the enumerable properties of `o` into this object.
#
# A target object property is overriden by the source property
# if both hold the same property.
#
#     target = foo: 10
#     target.merge bar: 20, baz: 30
#     # target = {foo: 10, bar: 20, baz: 30}
def merge: (o) -> @[k] = v for k,v of o

##### Object::reject

# Returns an object without the properties that are evaluated as `true`
# in the passed-in filter function.
#
#     source = foo: 10, bar: 20, baz: 30
#     target = source.reject (k,v) -> v > 10
#     # target = {foo: 10}
def reject: (f) -> o = {}; o[k] = v for k,v of this when not f? k, v; return o

##### Object::select

# Returns an object with the properties that are evaluated as `true`
# in the passed-in filter function.
#
#     source = foo: 10, bar: 20, baz: 30
#     target = source.select (k,v) -> v > 10
#     # target = {bar: 20, baz: 30}
def select: (f) -> o = {}; o[k] = v for k,v of this when f? k, v; return o

##### Object::size

# `Object::length` alias.
def size: -> @length()

##### Object::sortedKeys

# Returns the enumerable keys sorted alphabetically.
def sortedKeys: -> @keys().sort()

##### Object::sortedValues

# Returns the values of the enumerable properties of this object.
# The values are ordered such as each key in `sortedKeys` correspond
# to the value at the same index in `sortedValues`.
def sortedValues: -> @[k] for k in @sortedKeys()

##### Object::type

# Returns the results of calling `Object::toString` on the current object
# and extracting the class name to lower case.
def type: ->
  Object::toString.call(@).toLowerCase().replace /\[object (\w+)\]/, "$1"

##### Object::update

# `Object::merge` alias.
def update: -> (o) -> @merge o

##### Object::values

# Returns the values of the enumerable properties of this object.
# The values are returned as the `for..in` construct iterates on this object.
# Use `sortedValues` to retreive the values based on the alphabetically
# sorted keys.
def values: -> @[k] for k in @keys()

#### Duck Typing

##### Object::quacksLike

# The `Object::quacksLike` method allow to perform a duck test
# on the current object object.
#
# Duck tests are performed by looking for a special `__definition__` field
# on the passed-in `type` object. This field can either contains a function
# or an structure object.
#
# When using a structure object, the keys matched for properties name and
# values can be either a string that will be tested against `typeof value`
# (use `*` to allow any type) or a function that will be called with the
# value as argument.
#
# Below an example of how `quacksLike` can be used with custom
# type definitions:
#
#     Point =
#       __definition__:
#         x: 'number'
#         y: 'number'
#
#     class ConcretPoint
#       constructor: (@x=0, @y=0) ->
#
#     point = new ConcretPoint
#     point.quacksLike Point  # true
#
#     point.x = "foo"
#     point.quacksLike Point  # false
#
#     object = {x: 10, y: 20}
#     object.quacksLike Point # true
#
# An example demonstrating the use of function as definition:
#
#     Command =
#       __definition__: (o) ->
#         typeof o is "function" and o.aliases?
#
#     command = -> # do something
#     command.aliases = ['c', 'command']
#
#     command.quacksLike Command # true
#
# Of course, a class can describe itself in its body:
#
#     class Point
#       @__definition__:
#         x: 'number'
#         y: 'number'
#
#       constructor: (@x, @y) ->
def quacksLike: (type) ->
  if type.__definition__?
    definition = type.__definition__
    return definition this if typeof definition is "function"
    for k,v of definition
      switch typeof v
        when "function" then return false unless v @[k]
        else return false unless (v is "*" or @[k]?.type() is v)
    true
  else
    false


