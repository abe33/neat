require '../../../test_helper'
Neat = require '../../../../lib/neat'
{run} = require '../../../../lib/utils/commands'
{print} = require 'util'

options = {}
  # stderr: (data)-> print data
  # stdout: (data)-> print data

describe 'when outside a project', ->
  beforeEach -> process.chdir FIXTURES_ROOT

  describe 'running `neat generate initializer foo`', ->
    it "should return a status of 1 and don't generate anything", ->
      ended = false
      runs ->
        args = [NEAT_BIN, 'generate', 'initializer', 'foo']
        run 'node', args, options, (status) ->
          expect(status).toBe(1)
          ended = true

      waitsFor progress(-> ended), 'Timed out', 10000

withProject 'foo', ->
  describe 'running `neat generate initializer`', ->
    it "should return a status of 1 and don't generate anything", ->
      ended = false
      runs ->
        run 'node', [NEAT_BIN, 'generate', 'initializer'], options, (status) ->
          expect(status).toBe(1)
          ended = true

      waitsFor progress(-> ended), 'Timed out', 10000
  describe 'running `neat generate initializer foo`', ->
    it 'should generate a new initializer foo in the project', (done) ->
      run 'node', [NEAT_BIN, 'generate', 'initializer', 'foo'], (status) ->
        expect(inProject "src/config/initializers/foo.coffee").toExist()

        done()

  describe 'running `neat generate initializer bar/foo`', ->
    it 'should generate a new initializer foo in the project', (done) ->
      run 'node', [NEAT_BIN, 'generate', 'initializer', 'bar/foo'], (status) ->
        expect(inProject "src/config/initializers/bar/foo.coffee")
          .toExist()

        done()
