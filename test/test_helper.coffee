# TODO: Place your helpers definition here.
fs = require 'fs'
require '../lib/core'
{run} = require '../lib/utils/commands'
{resolve, existsSync:eS} = require 'path'
{rmSync:rm} = require resolve __dirname, '../lib/utils/files'

global.TEST_ROOT = resolve '.'
global.FIXTURES_ROOT = resolve __dirname, './fixtures/commands/generate'
global.NEAT_BIN = resolve __dirname, '../bin/neat'

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

global.withProject = (name, desc=null, block) ->
  [block, desc] = [desc, block] if typeof desc is 'function'

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
        run 'node', args, (status) =>
          process.chdir @projectPath
          ended = true

      waitsFor (-> ended), 'Timed out', 1000

    afterEach ->
      process.chdir TEST_ROOT
      rm @projectPath

    block()
