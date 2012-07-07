{resolve} = require 'path'
{spawn} = require 'child_process'
{compile} = require 'coffee-script'
{puts, error} = require './logs'

read = (str) ->
  try eval compile "#{str}", bare:true catch e then null

module.exports = {read}
