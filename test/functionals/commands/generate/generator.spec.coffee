require '../../../test_helper'
Neat = require '../../../../lib/neat'
{run} = require '../../../../lib/utils/commands'
{print} = require 'util'

options = {}
  # stderr: (data)-> print data
  # stdout: (data)-> print data

describe 'when outside a project', ->
  beforeEach -> process.chdir FIXTURES_ROOT

  describe 'running `neat generate generator foo`', ->
    it "should return a status of 1 and don't generate anything", ->
      ended = false
      runs ->
        args = [NEAT_BIN, 'generate', 'generator', 'foo']
        run 'node', args, options, (status) ->
          expect(status).toBe(1)
          ended = true

      waitsFor progress(-> ended), 'Timed out', 10000

withProject 'foo', ->
  describe 'running `neat generate generator`', ->
    it "should return a status of 1 and don't generate anything", ->
      ended = false
      runs ->
        run 'node', [NEAT_BIN, 'generate', 'generator'], options, (status) ->
          expect(status).toBe(1)
          ended = true

      waitsFor progress(-> ended), 'Timed out', 10000

  describe 'running `neat generate generator foo`', ->
    it 'should generate a new generator foo in the project', (done) ->
      run 'node', [NEAT_BIN, 'generate', 'generator', 'foo'], (status) ->
        path = inProject "src/generators/foo.gen.coffee"
        expect(path).toExist()
        expect(path).toContain("exports.foo = (generator, args..., cb) ->")

        done()

  describe 'running `neat generate generator bar/foo`', ->
    it 'should generate a new generator foo in the project', (done) ->
      run 'node', [NEAT_BIN, 'generate', 'generator', 'bar/foo'], (status) ->
        expect(inProject "src/generators/bar/foo.gen.coffee").toExist()

        done()
