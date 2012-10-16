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

##### Function.isAsync

# Returns `true` if the passed-in function accept a callback as last argument.
#
#     Function.isAsync ->             # false
#     Function.isAsync (callback) ->  # true
Function.isAsync = (fn) -> fn.signature().last() is 'callback'

##### Function::isAsync

# Returns `true` if the passed-in function accept a callback as last argument.
#
#     f1 = ->
#     f2 = (callback) ->
#     f1.isAsync() # false
#     f2.isAsync() # true
def Function, isAsync: -> Function.isAsync this

##### Function::signature

# Returns an array that contains the signature of the function.
#
#     f1 = ->
#     f2 = (a, b, c) ->
#     f1.signature() # []
#     f1.signature() # ['a', 'b', 'c']
def Function, signature: ->
  sign = Function.signRE.exec(@toString())[SIGN_POSITION]
  if sign is EMPTY_SIGNATURE then [] else sign.split Function.commaRE


def Function, callAsync: (context, args..., callback) ->
  if @isAsync()
    @apply context, args.concat callback
  else
    res = @apply context, args
    callback? res

def Function, applyAsync: (context, args, callback) ->
  if @isAsync()
    @apply context, args.concat callback
  else
    res = @apply context, args
    callback? res
