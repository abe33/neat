fs = require 'fs'
path = require 'path'

eS = fs.existsSync or path.existsSync

{exec} = require 'child_process'

Neat = require '../../lib/neat'
{run} = Neat.require 'utils/commands'
{rmSync:rm, ensurePath, touch} = Neat.require 'utils/files'

options = {}
  # stderr: (data)-> print data
  # stdout: (data)-> print data

global.withSourceFile = (file, content, callback) ->
  dir = file.split('/')[0..-2].join '/'
  ensurePath dir, (err) ->
    touch file, content, callback

global.withCompiledFile = (file, content, callback) ->
  dir = file.split('/')[0..-2].join '/'

  ensurePath dir, (err) ->
    touch file, content, (err) ->
      run 'cake', ['build'], (status) ->
        callback?()

global.withProject = (name, desc=null, block, opts) ->
  if typeof desc is 'function'
    [block, opts, desc] = [desc, block, opts]

  describe (desc or "within the generated project #{name}"), ->
    beforeEach ->
      @projectName = name
      @projectPath = "#{TEST_TMP_DIR}/#{name}"
      global.inProject = (p) -> "#{TEST_TMP_DIR}/#{name}/#{p}"

      addFileMatchers this

      process.chdir TEST_TMP_DIR
      ended = false
      runs ->
        args = [
          NEAT_BIN,
          'generate',
          'project',
          @projectName,
          'author:"John Doe"',
          'keywords:foo,bar,baz'
          'description:"a description"'
        ]
        run 'node', args, options, (status) =>
          @status = status
          process.chdir @projectPath
          if opts?.init?
            opts.init -> ended = true
          else
            ended = true

      waitsFor progress(-> ended), 'Timed out on project creation', 5000

    afterEach ->
      process.chdir TEST_ROOT
      unless opts?.noCleaning
        rm @projectPath if eS @projectPath


    block.call(this)

global.withBundledProject = (name, desc=null, block, opts) ->
  if typeof desc is 'function'
    [block, opts, desc] = [desc, block, opts]

  opts ||= {}
  init = opts.init

  opts.init = (callback) ->
    args = [
      '-s',
      "#{Neat.neatRoot}/lib",
      inProject('node_modules/neat')
    ]
    ensurePath inProject('node_modules'), ->
      run 'ln', args, (status) ->
        if init?
          init callback
        else
          callback?()

  withProject name, desc, block, opts

global.withGitInitialized = (block) ->
  beforeEach ->
    process.chdir @projectPath
    ended = false
    command = 'cake build;
               git init;
               git add .;
               git commit -am "First commit";
               git status'

    runs ->
      exec command, (err, stdout, stderr) =>
        # if err?
        #   console.log stderr
        # else
        #   console.log stdout
        throw err if err?
        ended = true

    waitsFor progress(-> ended), 'Timed out on git init', 5000

  block.call(this)

global.withPagesInitialized = (block) ->
  beforeEach ->
    process.chdir @projectPath
    ended = false
    command = "node #{NEAT_BIN} generate github:pages"

    runs ->
      exec command, (err, stdout, stderr) =>
        # if err?
        #   console.log stderr
        # else
        #   console.log stdout
        throw err if err?
        ended = true

    waitsFor progress(-> ended), 'Timed out on pages init', 5000

  block.call(this)
