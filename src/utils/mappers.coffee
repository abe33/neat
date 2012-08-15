
at = (index=0, mapper) -> (el) ->
  if mapper? then mapper el?[index] else el?[index]

first = (mapper) -> (el) ->
  if mapper? then mapper el?.first?() else el?.first?()

last = (mapper) -> (el) ->
  if mapper? then mapper el?.last?() else el?.last?()

length = -> (el) ->
  if typeof el?.length is 'function' then el?.length() else el?.length

property = (key, mapper) -> (el) -> if mapper? then mapper el[key] else el[key]

module.exports = {
  at,
  first,
  last,
  length,
  property,
}
