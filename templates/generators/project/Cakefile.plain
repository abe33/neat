fs = require 'fs'
{print} = require 'util'
{spawn} = require 'child_process'

try
  Neat = require 'neat'
  Neat.require 'core'

  # Loads all the tasks of the project.
  Neat.require 'tasks'
catch e
  unless 'compile' in process.argv
    print """Something gone wrong:

         #{e.stack}

         You can either run:
         - cake compile: Rebuild the project lib directory if a task is broken.
         - neat install: To install the dependencies if a module is missing.
         \n"""

  run = (cmd, args, cb) ->
    exe = spawn cmd, args
    exe.stdout.on 'data', (data) -> print data.toString()
    exe.stderr.on 'data', (data) -> print data.toString()
    exe.on 'exit', cb

  task 'compile', 'Compiles the sources', ->
    run 'coffee', ['-c', '-o', 'lib', 'src'], (status) ->
      if status is 0 then console.log 'Compilation done'
      else console.log 'Compilation failed'
