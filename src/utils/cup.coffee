{resolve} = require 'path'
{spawn} = require 'child_process'
{compile} = require 'coffee-script'
{puts, error} = require './logs'

read = (content) ->
  content = "#{content}"

  try
    src = compile content, bare:true
    eval src
  catch e
    null

module.exports = {read}
