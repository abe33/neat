{print} = require 'util'
{spawn} = require 'child_process'

try
  require './lib/core'
  Neat = require './lib'

  Neat.require 'tasks'
catch e
  unless 'compile' in process.argv
    console.log 'missing compiled files, run cake compile'

  task 'compile', 'Compiles the sources', ->
    exe = spawn 'coffee', ['-c', '-o', 'lib', 'src']
    exe.stdout.on 'data', (data) -> print data.toString()
    exe.stderr.on 'data', (data) -> print data.toString()
    exe.on 'exit', (status)->
      if status is 0 then console.log 'Compilation done'
      else console.log 'Compilation failed'



