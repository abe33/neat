fs = require 'fs'
{resolve, existsSync:eS} = require 'path'
{run} = require resolve __dirname, '../../../lib/utils/commands'
{rmSync:rm} = require resolve __dirname, '../../../lib/utils/files'

TEST_ROOT = resolve '.'
FIXTURES_ROOT = resolve __dirname, '../../../test/fixtures/commands/generate'
NEAT_BIN = resolve __dirname, '../../../bin/neat'

describe '`neat generate', ->
  beforeEach ->
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
      expect(eS "#{FIXTURES_ROOT}/foo/.neat").toBeTruthy()
      expect(eS "#{FIXTURES_ROOT}/foo/.gitignore").toBeTruthy()
      expect(eS "#{FIXTURES_ROOT}/foo/.npmignore").toBeTruthy()
      expect(eS "#{FIXTURES_ROOT}/foo/Cakefile").toBeTruthy()
      expect(eS "#{FIXTURES_ROOT}/foo/Nemfile").toBeTruthy()

      expect(eS "#{FIXTURES_ROOT}/foo/src/tasks/.gitkeep").toBeTruthy()
      expect(eS "#{FIXTURES_ROOT}/foo/src/commands/.gitkeep").toBeTruthy()
      expect(eS "#{FIXTURES_ROOT}/foo/src/generators/.gitkeep").toBeTruthy()

      expect(eS "#{FIXTURES_ROOT}/foo/src/config/initializers/.gitkeep")
        .toBeTruthy()
      expect(eS "#{FIXTURES_ROOT}/foo/src/config/environments/.gitkeep")
        .toBeTruthy()

      expect(eS "#{FIXTURES_ROOT}/foo/templates/.gitkeep").toBeTruthy()

      expect(eS "#{FIXTURES_ROOT}/foo/test/spec/.gitkeep").toBeTruthy()
      expect(eS "#{FIXTURES_ROOT}/foo/test/fixtures/.gitkeep").toBeTruthy()

  describe 'command foo`', ->
    beforeEach -> process.chdir "#{FIXTURES_ROOT}/foo"

    it 'should generate a new command foo in the project', (done) ->
      run 'node', [NEAT_BIN, 'generate', 'command', 'foo'], (status) ->

        expect(eS "#{FIXTURES_ROOT}/foo/src/commands/foo.cmd.coffee")
          .toBeTruthy()

        done()

  describe 'command bar/foo`', ->
    beforeEach -> process.chdir "#{FIXTURES_ROOT}/foo"

    it 'should generate a new command foo in the project', (done) ->
      run 'node', [NEAT_BIN, 'generate', 'command', 'bar/foo'], (status) ->

        expect(eS "#{FIXTURES_ROOT}/foo/src/commands/bar/foo.cmd.coffee")
          .toBeTruthy()

        done()

  describe 'task foo`', ->
    beforeEach -> process.chdir "#{FIXTURES_ROOT}/foo"

    it 'should generate a new task foo in the project', (done) ->
      run 'node', [NEAT_BIN, 'generate', 'task', 'foo'], (status) ->

        expect(eS "#{FIXTURES_ROOT}/foo/src/tasks/foo.cake.coffee")
          .toBeTruthy()

        done()

  describe 'task bar/foo`', ->
    beforeEach -> process.chdir "#{FIXTURES_ROOT}/foo"

    it 'should generate a new task foo in the project', (done) ->
      run 'node', [NEAT_BIN, 'generate', 'task', 'bar/foo'], (status) ->

        expect(eS "#{FIXTURES_ROOT}/foo/src/tasks/bar/foo.cake.coffee")
          .toBeTruthy()

        done()

  describe 'generator foo`', ->
    beforeEach -> process.chdir "#{FIXTURES_ROOT}/foo"

    it 'should generate a new generator foo in the project', (done) ->
      run 'node', [NEAT_BIN, 'generate', 'generator', 'foo'], (status) ->

        expect(eS "#{FIXTURES_ROOT}/foo/src/generators/foo.gen.coffee")
          .toBeTruthy()

        done()

  describe 'generator bar/foo`', ->
    beforeEach -> process.chdir "#{FIXTURES_ROOT}/foo"

    it 'should generate a new generator foo in the project', (done) ->
      run 'node', [NEAT_BIN, 'generate', 'generator', 'bar/foo'], (status) ->

        expect(eS "#{FIXTURES_ROOT}/foo/src/generators/bar/foo.gen.coffee")
          .toBeTruthy()

        done()

  describe 'initializer foo`', ->
    beforeEach -> process.chdir "#{FIXTURES_ROOT}/foo"

    it 'should generate a new initializer foo in the project', (done) ->
      run 'node', [NEAT_BIN, 'generate', 'initializer', 'foo'], (status) ->
        path= "#{FIXTURES_ROOT}/foo/src/config/initializers/foo.coffee"
        expect(eS path).toBeTruthy()

        done()

  describe 'initializer bar/foo`', ->
    beforeEach -> process.chdir "#{FIXTURES_ROOT}/foo"

    it 'should generate a new initializer foo in the project', (done) ->
      run 'node', [NEAT_BIN, 'generate', 'initializer', 'bar/foo'], (status) ->
        path= "#{FIXTURES_ROOT}/foo/src/config/initializers/bar/foo.coffee"
        expect(eS path).toBeTruthy()

        done()

  describe 'package`', ->
    beforeEach -> process.chdir "#{FIXTURES_ROOT}/foo"

    it 'should generate a package.json file at the project root', (done) ->
      run 'node', [NEAT_BIN, 'generate', 'package'], (status) ->

        expect(eS "#{FIXTURES_ROOT}/foo/package.json")
          .toBeTruthy()

        done()
