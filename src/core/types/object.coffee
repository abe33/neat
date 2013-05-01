# This file contains Object's extensions that mimics some of the ruby
# Object and Hash methods.
# @toc
{def} = require './utils'

## Object

#### Class Extensions

##### Object.new

# Creates a new object from an array such as `[key, value, key, value, ...]`.
#
#     o = Object.new ['foo', 10, 'bar', 20, 'baz', 30]
#     # {foo: 10, bar: 20, baz: 30}
Object.new = (a) -> o = {}; a.step(2, (k,v) -> o[k] = v); return o

#### Instances Extensions

##### Object::concat

# Returns a new object that is the result of the merge of the current
# object with the passed-in argument. If no argument is provided,
# the return a copy of the current object.
#
#     {foo: 'foo', bar: 'bar'}.concat baz: 'baz'
#     # {foo: 'foo', bar: 'bar', baz: 'baz'}
def Object, concat: (m) ->
  o = {}; o[k] = v for k,v of this; return o.merge(m || {})

##### Object::destroy

# Delete the given property and return its previous value.
#
#     o = {foo: 10, bar: 20}
#     o.destroy 'foo' # 10
#     # o = {bar: 20}
def Object, destroy: (key) ->
  if @hasKey key
    res = @[key]
    delete @[key]
    return res
  null

##### Object::each
#
# Iterates over the object enumerable properties and call
# the passed-in function with the key-value pair.
#
#     {foo: 10, bar: 20}.each (k,v) ->
#       # do something with k and v
def Object, each: (f) -> f k,v for k,v of this if f?; this

##### Object::empty

# Returns true if the current object don't contains any enumerable properties.
#
#     {}.empty()        # true
#     {foo: 10}.empty() # false
def Object, empty: -> @keys().empty()

##### Object::first

# Returns the first pair of key and value of the current object as a tuple.
#
#     {foo: 10, bar: 20}.first() # ['foo', 10]
def Object, first: -> if @empty() then null else @flatten().group(2).first()

##### Object::flatten

# Returns an array such as `[key, value, key, value]` with the name
# and the content of the enumerable properties of this object.
#
#     {foo: 10, bar: 20, baz: 30}.flatten()
#     # ['foo', 10, 'bar', 20, 'baz', 30]
def Object, flatten: -> a = []; a = a.concat [k,v] for k,v of this; return a

##### Object::has

# Retuns `true` if the specified values is contained in one of the object
# enumerable properties.
#
#     object =
#       foo: 10
#       bar: 20
#
#     object.has 20 # true
#     object.has 30 # false
def Object, has: (value) -> value in @values()

##### Object::hasKey

# Returns `true` if the specified key is defined on this object.
#
#     object =
#       foo: 10
#       bar: 20
#
#     object.hasKey 'foo' # true
#     object.hasKey 'baz' # false
def Object, hasKey: (key) -> @[key]?

##### Object::keys

# Returns an array of the keys enumerable on this object.
#
# The keys are returned as the `for..in` construct iterates on them.
# Use `sortedKeys` to retreive the keys sorted alphabetically.
#
#     object =
#       foo: 10
#       bar: 20
#
#     object.keys() # ['foo', 'bar']
def Object, keys: -> k for k of this

##### Object::length

# Returns the count of enumerable properties on this object.
#
#     {}.length()                 # 0
#     {foo: 10}.length()          # 1
#     {foo: 10, bar: 20}.length() # 2
def Object, length: -> @keys().length

##### Object::last

# Returns the last pair of key and value of the current object as a tuple.
#
#     {foo: 10, bar: 20}.last() # ['bar', 20]
def Object, last: -> if @empty() then null else @flatten().group(2).last()

##### Object::map

# Iterates over the current object enumerable properties and
# creates a new object with the mapping function's return.
#
#     source = {foo: 10, bar: 50}
#     result = source.map (k,v) -> ["_#{k}_", v * 100]
#     # {_foo_: 1000, _bar_: 5000}
def Object, map: (f) -> Object.new (f(k,v) for k,v of this).flatten()

##### Object::merge

# Merge the enumerable properties of `o` into this object.
#
# A target object property is overriden by the source property
# if both hold the same property.
#
#     target = foo: 10
#     target.merge bar: 20, baz: 30
#     # target = {foo: 10, bar: 20, baz: 30}
def Object, merge: (o) -> @[k] = v for k,v of o; this

##### Object::reject

# Returns an object without the properties that are evaluated as `true`
# in the passed-in filter function.
#
#     source = foo: 10, bar: 20, baz: 30
#     target = source.reject (k,v) -> v > 10
#     # target = {foo: 10}
def Object, reject: (f) ->
  o = {}; o[k] = v for k,v of this when not f? k, v; return o

##### Object::select

# Returns an object with the properties that are evaluated as `true`
# in the passed-in filter function.
#
#     source = foo: 10, bar: 20, baz: 30
#     target = source.select (k,v) -> v > 10
#     # target = {bar: 20, baz: 30}
def Object, select: (f) ->
  o = {}; o[k] = v for k,v of this when f? k, v; return o

##### Object::size

# `Object::length` alias.
def Object, size: -> @length()

##### Object::sort

# Returns a new object whose properties have been sorted to
# be iterated in the defined order.
#
#     source = foo: 10, bar: 20
#     target = source.sort (a,b) ->
#       if a > b then 1 else if b < a then -1 else 0
#     # target = {bar: 20, foo: 10}
#
# If called without arguments the keys are sorted alphabetically.
def Object, sort: (f) ->
  if not f? or typeof f isnt 'function'
    f = (a,b) ->
      if a > b then 1 else if b < a then -1 else 0

  o = {}; o[k] = @[k] for k in @keys().sort f; return o

##### Object::sortedKeys

# Returns the enumerable keys sorted alphabetically.
#
#     object =
#       foo: 10
#       bar: 20
#
#     object.sortedKeys() # ['bar', 'foo']
def Object, sortedKeys: -> @keys().sort()

##### Object::sortedValues

# Returns the values of the enumerable properties of this object.
# The values are ordered such as each key in `sortedKeys` correspond
# to the value at the same index in `sortedValues`.
#
#     object =
#       foo: 10
#       bar: 20
#
#     object.sortedValues() # [20, 10]
def Object, sortedValues: -> @[k] for k in @sortedKeys()

##### Object::tap

# Pass a block to the `tap` method in order to configure an object.
# The object is returned.
def Object, tap: (block) -> block.call(this, this); this

##### Object::type

# Returns the results of calling `Object::toString` on the current object
# and extracting the class name to lower case.
def Object, type: ->
  Object::toString.call(@).toLowerCase().replace /\[object (\w+)\]/, "$1"

##### Object::update

# `Object::merge` alias.
def Object, update: Object::merge

##### Object::values

# Returns the values of the enumerable properties of this object.
# The values are returned as the `for..in` construct iterates on this object.
# Use `sortedValues` to retreive the values based on the alphabetically
# sorted keys.
#
#     object =
#       foo: 10
#       bar: 20
#
#     object.values() # [10, 20]
def Object, values: -> @[k] for k in @keys()

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
def Object, quacksLike: (type) ->
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


