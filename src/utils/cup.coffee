{resolve} = require 'path'
{spawn} = require 'child_process'
{compile} = require 'coffee-script'
{puts, error} = require './logs'

read = (str) ->
  try eval compile "#{str}", bare:true catch e then null

write = (o) ->
  s = ''
  s += getMember k, v, o for k,v of o
  s.replace(/\n\s*\n|\s*\n/g, '\n').strip().replace(/\t/g, "*")

getMember = (k, v, o, i='') -> "#{k}: #{getValue v, i}\n"
getValue = (v, i='') ->
  switch typeof v
    when 'number' then v
    when 'string' then "'#{v}'"
    when 'boolean' then v
    when 'object'
      if RegExp::isPrototypeOf v then v
      else if Array::isPrototypeOf v
        "[#{("\n#{i}  #{getValue n, i}" for n in v).join ''}\n]"
      else
        ("\n#{i}  #{getMember m,o,v,i+'  '}" for m,o of v).join ''
    when 'function' then "`#{v.toString()}`"

module.exports = {read, write}
