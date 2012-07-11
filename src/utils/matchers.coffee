# This file contains a set of matchers that can be used in various situations
# such as array filters or duck tests.
# @toc

anyOf = (matchers...) -> (el) ->
  return true for m in matchers when m el
  false

allOf = (matchers...) -> (el) ->
  return false for m in matchers when not m el
  true

equalTo = (val) -> (el) -> el is val

greaterThan = (val) -> (el) -> el > val

greaterThanOrEqualTo = (val) -> (el) -> el >= val

hasProperty = (prop, val) -> (el) ->
  el[prop]? and if val?
    if typeof val is 'function' then val el[prop] else equalTo(val)(el[prop])
  else
    true

hasProperties = (propsets...) -> (el) ->
  results = true
  for propset in propsets
    if typeof propset is 'string'
      results &&= el[propset]?
    else
      for k,v of propset
        results &&= hasProperty(k,v)(el)
  results

isNot = (m) -> (el) -> if typeof m is 'function' then not m el else el isnt m

isNotNull = -> (el) -> el?

isNull = -> (el) -> not el?

isType = (type) -> (el) -> typeof el is type

lowerThan = (val) -> (el) -> el < val

lowerThanOrEqualTo = (val) -> (el) -> el <= val

quacksLike = (def) -> (el) -> el? and el.quacksLike def

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
