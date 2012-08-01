# TODO: Place your helpers definition here.
fs = require 'fs'
Neat = require '../lib/neat'
Neat.require 'core'

{run} = require '../lib/utils/commands'
{resolve, existsSync:eS} = require 'path'
{rmSync:rm, ensurePath} = require resolve __dirname, '../lib/utils/files'
{print} = require 'util'

global.TEST_ROOT = resolve '.'
global.FIXTURES_ROOT = '/tmp'
global.NEAT_BIN = resolve __dirname, '../bin/neat'

options = {}
  # stderr: (data)-> print data
  # stdout: (data)-> print data

cursor = 0
global.progress = (f) ->
  oldRes = false
  ->
    res = f.apply(this, arguments)
    p = Math.round(new Date().getMilliseconds() / 60) % 4
    setTimeout (-> print "\b" unless oldRes), 10
    print "#{'|/-\\'[p]}" unless res
    oldRes = res

global.addFileMatchers = (scope) ->
  scope.addMatchers
    toExist: () ->
      actual = @actual
      notText = if @isNot then " not" else ""

      @message = ->
        "Expected #{actual}#{notText} to exist"

      eS @actual

    toContain: (matcher) ->
      actual = @actual
      notText = if @isNot then " not" else ""

      @message = ->
        """Expected content:
           #{@content}
           of file #{actual}#{notText} to contains "#{@expected}" """

      @content = fs.readFileSync(@actual).toString()
      if typeof matcher is 'function'
        matcher.call scope, @content
      else
        @expected = matcher
        @content.indexOf(@expected) >= 0

global.withProject = (name, desc=null, block, opts) ->
  if typeof desc is 'function'
    [block, opts, desc] = [desc, block, opts]

  describe (desc or "within the generated project #{name}"), ->
    beforeEach ->
      @projectName = name
      @projectPath = "#{FIXTURES_ROOT}/#{name}"
      global.inProject = (p) -> "#{FIXTURES_ROOT}/#{name}/#{p}"

      addFileMatchers this

      process.chdir FIXTURES_ROOT
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
          process.chdir @projectPath
          if opts?.init?
            opts.init -> ended = true
          else
            ended = true

      waitsFor progress(-> ended), 'Timed out', 1000

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

