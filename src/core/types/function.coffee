{def} = require './utils'

Function.commaRE = /\s*,\s*/g

Function.asyncRE = /^function\s+([a-zA-Z_$][a-zA-Z0-9_$]*)*\([^)]*callback\)/

Function.signRE = /^function\s+([a-zA-Z_$][a-zA-Z0-9_$]*)*\(([^)]*)\)/
SIGN_POSITION = 2
EMPTY_SIGNATURE = ''

Function.isAsync = (fn) -> Function.asyncRE.test Function::toString.call fn

def Function, signature: ->
  sign = Function.signRE.exec(@toString())[SIGN_POSITION]
  if sign is EMPTY_SIGNATURE then [] else sign.split Function.commaRE
