require '../../../test_helper'
Neat = require '../../../../lib/neat'
{run} = require '../../../../lib/utils/commands'
{print} = require 'util'

options = {}
  # stderr: (data)-> print data
  # stdout: (data)-> print data

describe 'when outside a project', ->
  beforeEach -> process.chdir FIXTURES_ROOT

  describe 'running `neat generate spec:unit foo`', ->
    it "should return a status of 1 and don't generate anything", ->
      ended = false
      runs ->
        args = [NEAT_BIN, 'generate', 'spec:unit', 'foo']
        run 'node', args, options, (status) ->
          expect(status).toBe(1)
          ended = true

      waitsFor progress(-> ended), 'Timed out', 10000

  describe 'running `neat generate spec:functional foo`', ->
    it "should return a status of 1 and don't generate anything", ->
      ended = false
      runs ->
        args = [NEAT_BIN, 'generate', 'spec:functional', 'foo']
        run 'node', args, options, (status) ->
          expect(status).toBe(1)
          ended = true

      waitsFor progress(-> ended), 'Timed out', 10000

withProject 'foo', ->
  describe 'running `neat generate spec:unit`', ->
    it "should return a status of 1 and don't generate anything", ->
      ended = false
      runs ->
        run 'node', [NEAT_BIN, 'generate', 'spec:unit'], options, (status) ->
          expect(status).toBe(1)
          ended = true

      waitsFor progress(-> ended), 'Timed out', 10000

  describe 'running `neat generate spec:functional`', ->
    it "should return a status of 1 and don't generate anything", ->
      ended = false
      runs ->
        args = [NEAT_BIN, 'generate', 'spec:functional']
        run 'node', args, options, (status) ->
          expect(status).toBe(1)
          ended = true

      waitsFor progress(-> ended), 'Timed out', 10000

  describe 'running `neat generate spec:unit foo`', ->
    it 'should generate a new spec foo in the project', (done) ->
      run 'node', [NEAT_BIN, 'generate', 'spec:unit', 'foo'], (status) ->
        path = inProject "test/units/foo.spec.coffee"
        expect(path).toExist()
        expect(path).toContain("describe 'foo', ->")
        expect(path).toContain("require '../test_helper'")

        done()

  describe 'running `neat generate spec:unit bar/foo`', ->
    it 'should generate a new spec foo in the project', (done) ->
      run 'node', [NEAT_BIN, 'generate', 'spec:unit', 'bar/foo'], (status) ->
        path = inProject "test/units/bar/foo.spec.coffee"
        expect(path).toExist()
        expect(path).toContain("describe 'foo', ->")
        expect(path).toContain("require '../../test_helper'")

        done()

  describe 'running `neat generate spec:functional foo`', ->
    it 'should generate a new spec foo in the project', (done) ->
      run 'node', [NEAT_BIN, 'generate', 'spec:functional', 'foo'], (status) ->
        path = inProject "test/functionals/foo.spec.coffee"
        expect(path).toExist()
        expect(path).toContain("describe 'foo', ->")
        expect(path).toContain("require '../test_helper'")

        done()

  describe 'running `neat generate spec:functional bar/foo`', ->
    it 'should generate a new spec foo in the project', (done) ->
      args = [NEAT_BIN, 'generate', 'spec:functional', 'bar/foo']
      run 'node', args, (status) ->
        path = inProject "test/functionals/bar/foo.spec.coffee"
        expect(path).toExist()
        expect(path).toContain("describe 'foo', ->")
        expect(path).toContain("require '../../test_helper'")

        done()
