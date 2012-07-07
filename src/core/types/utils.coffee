#### Helpers

# Defines a non-enumerable property on `Object.prototype`.
def = (ctor, o) ->
  for name, value of o
    unless ctor.prototype[name]?
      Object.defineProperty? ctor.prototype,
                             name,
                             enumerable: false, value: value

module.exports = {def}
