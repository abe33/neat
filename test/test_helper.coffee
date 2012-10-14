# TODO: Place your helpers definition here.
fs = require 'fs'
Neat = require '../lib/neat'
Neat.require 'core'

{run} = require '../lib/utils/commands'
{resolve} = require 'path'
{rmSync:rm, ensurePath, touch} = Neat.require 'utils/files'
{print} = require 'util'

global.TEST_ROOT = resolve '.'
global.FIXTURES_ROOT = '/tmp'
global.NEAT_BIN = resolve __dirname, '../bin/neat'

eS = fs.existsSync

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

      return false unless eS @actual

      @content = fs.readFileSync(@actual).toString()
      if typeof matcher is 'function'
        matcher.call scope, @content
      else
        @expected = matcher
        @content.indexOf(@expected) >= 0

global.withSourceFile = (file, content, callback) ->
  dir = file.split('/')[0..-2].join '/'
  ensurePath dir, (err) ->
    touch file, content, callback

global.withCompiledFile = (file, content, callback) ->
  dir = file.split('/')[0..-2].join '/'

  ensurePath dir, (err) ->
    touch file, content, (err) ->
      run 'cake', ['compile'], (status) ->
        callback?()

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

global.testSimpleGenerator= (name, dir, ext) ->
  describe 'when outside a project', ->
    beforeEach -> process.chdir FIXTURES_ROOT

    describe "running `neat generate #{name} 'foo'`", ->
      it "should return a status of 1 and don't generate anything", ->
        ended = false
        runs ->
          args = [NEAT_BIN, 'generate', name, 'foo']
          run 'node', args, options, (status) ->
            expect(status).toBe(1)
            ended = true

        waitsFor progress(-> ended), 'Timed out', 10000

  withProject 'foo', ->
    describe "running `neat generate #{name}`", ->
      it "should return a status of 1 and don't generate anything", ->
        ended = false
        runs ->
          run 'node', [NEAT_BIN, 'generate', name], options, (status) ->
            expect(status).toBe(1)
            ended = true

        waitsFor progress(-> ended), 'Timed out', 10000

    describe "running `neat generate #{name} foo`", ->
      it "should generate a new #{name} foo in the project", (done) ->
        run 'node', [NEAT_BIN, 'generate', name, 'foo'], (status) ->
          expect(inProject "#{dir}/foo#{ext}").toExist()

          done()

    describe "running `neat generate #{name} bar/foo`", ->
      it "should generate a new #{name} foo in the project", (done) ->
        run 'node', [NEAT_BIN, 'generate', name, 'bar/foo'], (status) ->
          expect(inProject "#{dir}/bar/foo#{ext}")
            .toExist()

          done()

    describe "with a file already existing at the same path", ->
      it "should return a status of 1 and don't generate anything", ->
        ended = false
        runs ->
          withSourceFile "#{dir}/foo#{ext}", 'original_content', ->
            args = [NEAT_BIN, 'generate', name, 'foo']
            run 'node', args, options, (status) ->
              expect(status).toBe(1)
              expect("#{dir}/foo#{ext}").toExist()
              expect("#{dir}/foo#{ext}").toContain('original_content')
              ended = true

          waitsFor progress(-> ended), 'Timed out', 10000
