require '../../test_helper'
fs = require 'fs'
{resolve, existsSync:eS} = require 'path'
{run} = require resolve __dirname, '../../../lib/utils/commands'
{rmSync:rm} = require resolve __dirname, '../../../lib/utils/files'

TEST_ROOT = resolve '.'
FIXTURES_ROOT = resolve __dirname, '../../../test/fixtures/commands/generate'
NEAT_BIN = resolve __dirname, '../../../bin/neat'

describe '`neat generate', ->
  beforeEach ->
    @addMatchers
      toExist: () ->
        actual = @actual
        notText = if @isNot then " not" else ""

        @message = ->
         "Expected #{actual}#{notText} to exist"

        eS @actual

    process.chdir FIXTURES_ROOT
    ended = false
    runs ->
      run 'node', [NEAT_BIN, 'generate', 'project', 'foo'], (status) ->
        ended = true
    waitsFor (-> ended), 'Timed out', 1000

  afterEach ->
    process.chdir TEST_ROOT
    rm "#{FIXTURES_ROOT}/foo"

  describe 'project foo`', ->
    it 'should generates a project in the current directory', ->
      expect("#{FIXTURES_ROOT}/foo/.neat").toExist()
      expect("#{FIXTURES_ROOT}/foo/.gitignore").toExist()
      expect("#{FIXTURES_ROOT}/foo/.npmignore").toExist()
      expect("#{FIXTURES_ROOT}/foo/Cakefile").toExist()
      expect("#{FIXTURES_ROOT}/foo/Nemfile").toExist()

      expect("#{FIXTURES_ROOT}/foo/src/tasks/.gitkeep").toExist()
      expect("#{FIXTURES_ROOT}/foo/src/commands/.gitkeep").toExist()
      expect("#{FIXTURES_ROOT}/foo/src/generators/.gitkeep").toExist()

      expect("#{FIXTURES_ROOT}/foo/src/config/initializers/.gitkeep")
        .toExist()
      expect("#{FIXTURES_ROOT}/foo/src/config/environments/.gitkeep")
        .toExist()

      expect("#{FIXTURES_ROOT}/foo/templates/.gitkeep").toExist()

      expect("#{FIXTURES_ROOT}/foo/test/test_helper.coffee").toExist()
      expect("#{FIXTURES_ROOT}/foo/test/units/.gitkeep").toExist()
      expect("#{FIXTURES_ROOT}/foo/test/functionals/.gitkeep").toExist()
      expect("#{FIXTURES_ROOT}/foo/test/integrations/.gitkeep").toExist()
      expect("#{FIXTURES_ROOT}/foo/test/fixtures/.gitkeep").toExist()

  describe 'command foo`', ->
    beforeEach -> process.chdir "#{FIXTURES_ROOT}/foo"

    it 'should generate a new command foo in the project', (done) ->
      run 'node', [NEAT_BIN, 'generate', 'command', 'foo'], (status) ->

        expect("#{FIXTURES_ROOT}/foo/src/commands/foo.cmd.coffee")
          .toExist()

        done()

  describe 'command bar/foo`', ->
    beforeEach -> process.chdir "#{FIXTURES_ROOT}/foo"

    it 'should generate a new command foo in the project', (done) ->
      run 'node', [NEAT_BIN, 'generate', 'command', 'bar/foo'], (status) ->

        expect("#{FIXTURES_ROOT}/foo/src/commands/bar/foo.cmd.coffee")
          .toExist()

        done()

  describe 'task foo`', ->
    beforeEach -> process.chdir "#{FIXTURES_ROOT}/foo"

    it 'should generate a new task foo in the project', (done) ->
      run 'node', [NEAT_BIN, 'generate', 'task', 'foo'], (status) ->

        expect("#{FIXTURES_ROOT}/foo/src/tasks/foo.cake.coffee")
          .toExist()

        done()

  describe 'task bar/foo`', ->
    beforeEach -> process.chdir "#{FIXTURES_ROOT}/foo"

    it 'should generate a new task foo in the project', (done) ->
      run 'node', [NEAT_BIN, 'generate', 'task', 'bar/foo'], (status) ->

        expect("#{FIXTURES_ROOT}/foo/src/tasks/bar/foo.cake.coffee")
          .toExist()

        done()

  describe 'generator foo`', ->
    beforeEach -> process.chdir "#{FIXTURES_ROOT}/foo"

    it 'should generate a new generator foo in the project', (done) ->
      run 'node', [NEAT_BIN, 'generate', 'generator', 'foo'], (status) ->

        expect("#{FIXTURES_ROOT}/foo/src/generators/foo.gen.coffee")
          .toExist()

        done()

  describe 'generator bar/foo`', ->
    beforeEach -> process.chdir "#{FIXTURES_ROOT}/foo"

    it 'should generate a new generator foo in the project', (done) ->
      run 'node', [NEAT_BIN, 'generate', 'generator', 'bar/foo'], (status) ->

        expect("#{FIXTURES_ROOT}/foo/src/generators/bar/foo.gen.coffee")
          .toExist()

        done()

  describe 'initializer foo`', ->
    beforeEach -> process.chdir "#{FIXTURES_ROOT}/foo"

    it 'should generate a new initializer foo in the project', (done) ->
      run 'node', [NEAT_BIN, 'generate', 'initializer', 'foo'], (status) ->
        path= "#{FIXTURES_ROOT}/foo/src/config/initializers/foo.coffee"
        expect(path).toExist()

        done()

  describe 'initializer bar/foo`', ->
    beforeEach -> process.chdir "#{FIXTURES_ROOT}/foo"

    it 'should generate a new initializer foo in the project', (done) ->
      run 'node', [NEAT_BIN, 'generate', 'initializer', 'bar/foo'], (status) ->
        path= "#{FIXTURES_ROOT}/foo/src/config/initializers/bar/foo.coffee"
        expect(path).toExist()

        done()

  describe 'spec:unit foo`', ->
    beforeEach -> process.chdir "#{FIXTURES_ROOT}/foo"

    it 'should generate a new spec foo in the project unit tests', (done) ->
      run 'node', [NEAT_BIN, 'generate', 'spec:unit', 'foo'], (status) ->
        path= "#{FIXTURES_ROOT}/foo/test/units/foo.spec.coffee"
        expect(path).toExist()

        done()

  describe 'spec:unit bar/foo`', ->
    beforeEach -> process.chdir "#{FIXTURES_ROOT}/foo"

    it 'should generate a new spec foo in the project unit tests', (done) ->
      run 'node', [NEAT_BIN, 'generate', 'spec:unit', 'bar/foo'], (status) ->
        path= "#{FIXTURES_ROOT}/foo/test/units/bar/foo.spec.coffee"
        expect(path).toExist()

        done()

  describe 'spec:functional foo`', ->
    beforeEach -> process.chdir "#{FIXTURES_ROOT}/foo"

    it 'should generate a new spec foo in the
        project functional tests'.squeeze(), (done) ->
      run 'node', [NEAT_BIN, 'generate', 'spec:functional', 'foo'], (status) ->
        path= "#{FIXTURES_ROOT}/foo/test/functionals/foo.spec.coffee"
        expect(path).toExist()

        done()

  describe 'spec:functional bar/foo`', ->
    beforeEach -> process.chdir "#{FIXTURES_ROOT}/foo"

    it 'should generate a new spec foo in the project
        functional tests'.squeeze(), (done) ->
      args = [NEAT_BIN, 'generate', 'spec:functional', 'bar/foo']
      run 'node', args, (status) ->
        path= "#{FIXTURES_ROOT}/foo/test/functionals/bar/foo.spec.coffee"
        expect(path).toExist()

        done()

  describe 'spec:integration foo`', ->
    beforeEach -> process.chdir "#{FIXTURES_ROOT}/foo"

    it 'should generate a new spec foo in the
        project integration tests'.squeeze(), (done) ->
      args = [NEAT_BIN, 'generate', 'spec:integration', 'foo']
      run 'node', args, (status) ->
        path= "#{FIXTURES_ROOT}/foo/test/integrations/foo.spec.coffee"
        expect(path).toExist()

        done()

  describe 'spec:integration bar/foo`', ->
    beforeEach -> process.chdir "#{FIXTURES_ROOT}/foo"

    it 'should generate a new spec foo in the project
        integration tests'.squeeze(), (done) ->
      args = [NEAT_BIN, 'generate', 'spec:integration', 'bar/foo']
      run 'node', args, (status) ->
        path= "#{FIXTURES_ROOT}/foo/test/integrations/bar/foo.spec.coffee"
        expect(path).toExist()

        done()

  describe 'package`', ->
    beforeEach -> process.chdir "#{FIXTURES_ROOT}/foo"

    it 'should generate a package.json file at the project root', (done) ->
      run 'node', [NEAT_BIN, 'generate', 'package'], (status) ->

        expect("#{FIXTURES_ROOT}/foo/package.json")
          .toExist()

        done()
