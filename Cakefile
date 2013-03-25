fs = require 'fs'
{print} = require 'util'
{spawn} = require 'child_process'

try
  Neat = require './lib'

  Neat.require 'tasks'
catch e
  unless 'compile' in process.argv or
         'install' in process.argv
    print "#{e.stack}\n\n"
    console.log 'Missing compiled files, run cake compile'

  NPM_TOKEN = '###_NPM_DECLARATION_###'
  ENV_TOKEN = '###_ENV_###'
  NPM_TEMPLATE = 'templates/commands/install.plain'
  NEMFILE = 'Nemfile'
  COFFEE = 'coffee'

  run = (cmd, args, cb) ->
    exe = spawn cmd, args
    exe.stdout.on 'data', (data) -> print data.toString()
    exe.stderr.on 'data', (data) -> print data.toString()
    exe.on 'exit', (status)-> cb? status

  task 'compile', 'Compiles the sources', ->
    run COFFEE, ['-c', '-o', 'lib', 'src'], (status) ->
      if status is 0 then console.log 'Compilation done'
      else console.log 'Compilation failed'

  task 'install', 'Install the neat dependencies through npm', ->
    # The content of the `Nemfile` file is inserted in a placeholder in
    # the `templates/commands/install.plain` file that contains the `npm`
    # function declaration.
    fs.readFile NPM_TEMPLATE, (err, nem) ->
      return print err if err?
      fs.readFile NEMFILE, (err, nemfile) ->
        return print err if err?

        source = nem.toString().replace NPM_TOKEN, nemfile.toString()
        source = source.replace ENV_TOKEN,
                                "env = '#{process.env['NEAT_ENV'] || 'all'}'"

        # The produced source code is then executed by `coffee`.
        run COFFEE, [ '-e', source ], (status) ->
          if status is 0
            console.log 'Neat dependencies installed'
          else
            console.log 'Neat dependencies installation failed'



