
parallel = (fns, callback) ->
  count = 0
  cb = -> count += 1; if count is fns.length then callback?()
  if fns.empty() then callback() else fn cb for fn in fns

queue = (fns, callback) ->
  next = -> if fns.empty() then callback() else fns.shift() next
  next()

chain = (fns, args..., callback) ->
  next = (args...) ->
    if fns.empty()
      callback.apply null, args
    else
      fns.shift().apply null, args.concat next

  next.apply null, args

module.exports = {queue, parallel, chain}
