# This file contains the extensions to the `Function` class.
# @toc
{def} = require './utils'

##### Function.commaRE

# A `Regexp` that matches the comma in a function signature.
Function.commaRE = /\s*,\s*/g

##### Function.signRE

# A `Regexp` that matches the signature of a function.
Function.signRE = /^function\s+([a-zA-Z_$][a-zA-Z0-9_$]*)*\(([^)]*)\)/
# The position of the function signature capture group.
SIGN_POSITION = 2
# A string to match empty function signature.
EMPTY_SIGNATURE = ''
# A string to match the callback argument
CALLBACK = 'callback'

##### Function.isAsync

# Returns `true` if the passed-in function accept a callback as last argument.
#
#     Function.isAsync ->             # false
#     Function.isAsync (callback) ->  # true
Function.isAsync = (fn) -> fn.signature().last() is CALLBACK

##### Function::isAsync

# Returns `true` if the passed-in function accept a callback as last argument.
#
#     f = ->
#     f.isAsync() # false
#
#     f = (callback) ->
#     f.isAsync() # true
def Function, isAsync: -> Function.isAsync this

##### Function::signature

# Returns an array that contains the signature of the function.
#
#     f = ->
#     f.signature() # []
#
#     f = (a, b, c) ->
#     f.signature() # ['a', 'b', 'c']
def Function, signature: ->
  sign = Function.signRE.exec(@toString())[SIGN_POSITION]
  if sign is EMPTY_SIGNATURE then [] else sign.split Function.commaRE

##### Function::callAsync

# Realize the call of the function in the given `context` asynchronously.
# It means that the `callback` function will be called either if the function
# is asynchronous or not.
#
#     f = (a, b) -> a + b
#     f.callAsync null, 2, 4, (res) -> # res = 6
#
#     f = (callback) -> callback? a + b
#     f.callAsync null, 2, 4, (res) -> # res = 6
def Function, callAsync: (context, args..., callback) ->
  if @isAsync()
    @apply context, args.concat callback
  else
    res = @apply context, args
    callback? res

##### Function::applyAsync

# Realize the call of the function in the given `context` asynchronously.
# It means that the `callback` function will be called either if the function
# is asynchronous or not.
#
#     f = (a, b) -> a + b
#     f.applyAsync null, [2, 4], (res) -> # res = 6
#
#     f = (callback) -> callback? a + b
#     f.applyAsync null, [2, 4], (res) -> # res = 6
def Function, applyAsync: (context, args, callback) ->
  if @isAsync()
    @apply context, args.concat callback
  else
    res = @apply context, args
    callback? res
