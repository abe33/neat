fs = require 'fs'
path = require 'path'
{print} = require 'util'
{resolve} = require 'path'
{exec} = require 'child_process'

Neat = require '../lib/neat'
Neat.require 'core'
{run} = require '../lib/utils/commands'
{rmSync:rm, ensurePath, touch} = Neat.require 'utils/files'
{findSync} = Neat.require "utils/files"

paths = Neat.paths.map (p) -> "#{p}/test/helpers"
files = findSync 'coffee', paths
files.forEach (f) -> require f

global.TEST_ROOT = resolve '.'
global.TEST_TMP_DIR = '/tmp'
global.FIXTURES_ROOT = resolve Neat.neatRoot, 'test/fixtures'
global.NEAT_BIN = resolve __dirname, '../bin/neat'

eS = fs.existsSync or path.existsSync

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

global.fixture = (path) -> resolve FIXTURES_ROOT, path

global.addDateMatchers = (scope) ->
  scope.addMatchers
    toEqualDate: (date) ->
      notText = if @isNot then " not" else ""
      @message = ->
        "Expected #{@actual}#{notText} to be a date equal to #{date}"

      @actual.getYear() is date.getYear() and
      @actual.getMonth() is date.getMonth() and
      @actual.getDate() is date.getDate() and
      @actual.getHours() is date.getHours() and
      @actual.getMinutes() is date.getMinutes() and
      @actual.getSeconds() is date.getSeconds()

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

currentBranch = (status) ->
  status.split('\n').shift().replace /\# On branch (.+)$/gm, '$1'

hasUntrackedFile = (status) -> status.indexOf('Untracked files:') isnt -1
hasUnstagedChanges = (status) -> status.indexOf('Changes not staged') isnt -1

global.git =
  should:
    haveBranch: (branch) ->
      it "should have a branch #{branch}", ->
        ended = false
        runs ->
          exec 'git branch', (err, branches) ->
            throw err if err?
            branches = branches.split('\n').map (b) -> b[2..]
            branches.pop()
            expect(branch in branches).toBeTruthy()
            ended = true

        waitsFor progress(-> ended), 'Timed out on git branch', 1000
    beInBranch: (branch) ->
      it "should be in branch #{branch}", ->
        ended = false
        runs ->
          exec 'git status', (err, status) ->
            throw err if err?
            current = currentBranch status
            expect(current).toBe(branch)
            ended = true

        waitsFor progress(-> ended), 'Timed out on git status', 1000
    not:
      haveUnstagedChange: ->
        it "should not have unstaged changes", ->
          ended = false
          runs ->
            exec 'git status', (err, status) ->
              throw err if err?
              expect(hasUnstagedChanges status).toBeFalsy()
              ended = true

          waitsFor progress(-> ended), 'Timed out on git status', 1000

      haveUntrackedFiles: ->
        it "should not have untracked files", ->
          ended = false
          runs ->
            exec 'git status', (err, status) ->
              throw err if err?
              expect(hasUntrackedFile status).toBeFalsy()
              ended = true

          waitsFor progress(-> ended), 'Timed out on git status', 1000

  inBranch: (branch, block) ->
    describe "in branch #{branch}", ->
      beforeEach ->
        ended = false
        runs ->
          exec 'git checkout gh-pages', (err) ->
            throw err if err?
            ended = true

        waitsFor progress(-> ended), 'Timed out on git checkout gh-pages', 1000

      block.call this

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
    command = 'cake compile;
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

global.testSimpleGenerator= (name, dir, ext) ->
  describe 'when outside a project', ->
    beforeEach -> process.chdir TEST_TMP_DIR

    describe "running `neat generate #{name} 'foo'`", ->
      it "should return a status of 1 and don't generate anything", ->
        ended = false
        runs ->
          args = [NEAT_BIN, 'generate', name, 'foo']
          run 'node', args, options, (status) ->
            expect(status).toBe(1)
            ended = true

        waitsFor progress(-> ended), 'Timed out', 10000

  withProject 'neat_project', ->
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
          withSourceFile inProject("#{dir}/foo#{ext}"), 'original_content', ->
            args = [NEAT_BIN, 'generate', name, 'foo']
            run 'node', args, options, (status) ->
              expect(status).toBe(1)
              expect("#{dir}/foo#{ext}").toExist()
              expect("#{dir}/foo#{ext}").toContain('original_content')
              ended = true

          waitsFor progress(-> ended), 'Timed out', 10000
