# This file contains utilities to deal with prototype extensions.

#### def

# Defines a non-enumerable property on the specified constructor's `prototype`.
#
#     def Object, merge: (o) ->
#       # merge implementation
#
#     {foo: 10}.merge bar: 20 # {foo: 10, bar: 20}
def = (ctor, o) ->
  for name, value of o
    Object.defineProperty? ctor.prototype,
                           name,
                           enumerable: false, value: value, writable: true

module.exports = {def}
