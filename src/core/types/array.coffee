# This file contains Array's extensions that mimics some of the ruby
# Array methods.
# @toc
{def} = require './utils'

## Array

#### Class Extensions

##### Array.isArray

# Returns `true` if the passed-in object is an `Array`. This function
# use the `Object.prototype.toString` hack to test the passed-in object.
Array.isArray = (a) -> Object::toString.call(a) is '[object Array]'

#### Instances Extensions

##### Array::compact

# Returns a new array without all the undefined elements of the previous array.
#
#     ['foo', null, 10].compact() # ['foo', 10]
def Array, compact: -> @select (el) -> el?

##### Array::empty

# Returns `true` if the array is empty.
#
#     [].empty()      # true
#     ['foo'].empty() # false
def Array, empty: -> @length is 0

##### Array::first

# Returns the first element in this array.
#
#     ['foo', 'bar'].first() # 'foo'
def Array, first: -> if @length > 0 then @[0] else undefined

##### Array::flatten

# Returns a new array that is a recursice one-dimensional flattening
# of this array.
# The `level` argument allow to specify the depth at which stopping
# the flattening.
#
#     [0, [1, 2, [3, 4, [5]]]].flatten()  # [0, 1, 2, 3, 4, 5]
#     [0, [1, 2, [3, 4, [5]]]].flatten(1) # [0, 1, 2, [3, 4, [5]]]
#     [0, [1, 2, [3, 4, [5]]]].flatten(2) # [0, 1, 2, 3, 4, [5]]
def Array, flatten: (level = Infinity) ->
  level = Infinity if level < 0
  a = []
  for el in this
    if Array.isArray(el) and level isnt 0
      a = a.concat el.flatten(level-1)
    else
      a.push el
  a

##### Array::group

# Returns an array whose values are grouped together in arrays
# of length `size`.
#
#     ['foo', 'bar', 'baz'].group 2
#     # [['foo', 'bar'], ['baz']]
def Array, group: (size) ->
  a = []; @step(size, -> a.push (v for v in arguments)); return a

##### Array::last

# Returns the last element in this array.
#
#     ['foo', 'bar'].last() # 'bar'
def Array, last: -> if @length > 0 then @[@length-1] else undefined

##### Array::max

# Returns the maximum value contained in this array.
#
#     [0, 10, 20, 30].max() # 30
def Array, max: -> Math.max.apply null, this

##### Array::min

# Returns the minimum value contained in this array.
#
#     [0, 10, 20, 30].min() # 0
def Array, min: -> Math.min.apply null, this

##### Array::reject

# Returns a new array that contains the elements of this array that wasn't
# rejected by the provided function.
# If no function is provided a copy of this array is returned.
#
#     ['foo', 'bar', 'baz'].reject (v) -> v.substr(0, 1) is "b"
#     # ['foo']
def Array, reject: (f) -> o for o in this when not f? o

##### Array::rotate

# Returns a new array which contains the elements of this array rotated
# according to the passed-in amount.
# The original array is leaved unchanged.
#
#     ['a', 'b', 'c', 'd'].rotate()   # ['b', 'c', 'd', 'a']
#     ['a', 'b', 'c', 'd'].rotate(2)  # ['c', 'd', 'a', 'b']
#     ['a', 'b', 'c', 'd'].rotate(-1) # ['d', 'a', 'b', 'c']
def Array, rotate: (amount=1) ->
  amount = 1 if amount is 0
  direction = amount > 0
  out = @concat()
  range = [0..Math.abs(amount)-1]
  if direction
    out.push out.shift() for i in range
  else
    out.unshift out.pop() for i in range
  out

##### Array::select

# Returns a new array which contains the elements of this array that
# was selected by the provided function.
# If no function is provided an empty array is returned.
#
#     ['foo', 'bar', 'baz'].select (v) -> v.substr(0, 1) is "b"
#     # ['bar', 'baz']
def Array, select: (f) -> o for o in this when f? o

##### Array::step

# Iterates over the array according to the given step.
#
#     ['foo', 'bar', 'baz'].step 2, (a, b) -> console.log a, b
#     # 'foo' 'bar'
#     # 'baz' undefined
def Array, step: (n,f) ->
  f?.apply this, @[i*n..i*n + n-1] for i in [0..Math.ceil(@length / n)-1]

##### Array::uniq

# Returns a new array where all values are unique.
#
#     ['foo', 'foo', 'bar'].uniq() # ['foo', 'bar']
def Array, uniq: ->
  out = []
  out.push v for v in this when v not in out
  out

