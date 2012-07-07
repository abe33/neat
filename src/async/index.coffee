
parallel = (fns, callback) ->
  count = 0
  cb = -> count += 1; if count is fns.length then callback?()
  if fns.empty() then callback() else fn cb for fn in fns

queue = (fns, callback) ->
  next = -> if fns.empty() then callback() else fns.shift() next
  next()

module.exports = {queue, parallel}
