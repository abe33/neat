# A bunch of functions to deals with asynchronous process.
# @toc

##### parallel

# Execute an array of functions `fns` in parallel. The passed-in `callback`
# will only be called when the all functions have call back.
#
#     f1 = (cb) -> setTimeout cb, 100
#     f2 = (cb) -> setTimeout cb, 200
#     parallel [f1, f2], ->
#       # called after both f1 and f2 have call back
parallel = (fns, callback) ->
  count = 0
  results = []
  cb = (res) ->
    count += 1
    results.push(res)
    if count is fns.length then callback? results

  if fns.empty() then callback [] else fn cb for fn in fns

##### queue

# Execute an array of functions `fns` one after the other.
# The passed-in `callback` will only be called when the last
# function have callback.
#
#     f1 = (cb) -> setTimeout cb, 100
#     f2 = (cb) -> setTimeout cb, 200
#     queue [f1, f2], ->
#       # called after at least 300ms
queue = (fns, callback) ->
  next = -> if fns.empty() then callback() else fns.shift() next
  next()

##### chain

# Execute an array of functions `fns` one after the other, like a `queue`,
# but the difference between them lies in the fact that a `chain` pass
# the arguments receive as argument of the callback function to the next
# function to execute.
#
#     f1 = (a, cb) -> setTimeout cb, 100, a+10
#     f2 = (a, cb) -> setTimeout cb, 200, a+20
#     chain [f1, f2], 0, (a) ->
#       # a is 30
chain = (fns, args..., callback) ->
  next = (args...) ->
    if fns.empty()
      callback.apply null, args
    else
      fns.shift().apply null, args.concat next

  next.apply null, args

module.exports = {queue, parallel, chain}
