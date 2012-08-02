require '../../../test_helper'
Neat = require '../../../../lib/neat'
{run} = require '../../../../lib/utils/commands'
{print} = require 'util'

options = {}
  # stderr: (data)-> print data
  # stdout: (data)-> print data

describe 'when outside a project', ->
  beforeEach -> process.chdir FIXTURES_ROOT

  describe 'running `neat generate task foo`', ->
    it "should return a status of 1 and don't generate anything", ->
      ended = false
      runs ->
        args = [NEAT_BIN, 'generate', 'task', 'foo']
        run 'node', args, options, (status) ->
          expect(status).toBe(1)
          ended = true

      waitsFor progress(-> ended), 'Timed out', 10000

withProject 'foo', ->
  describe 'running `neat generate task`', ->
    it "should return a status of 1 and don't generate anything", ->
      ended = false
      runs ->
        run 'node', [NEAT_BIN, 'generate', 'task'], options, (status) ->
          expect(status).toBe(1)
          ended = true

      waitsFor progress(-> ended), 'Timed out', 10000

  describe 'running `neat generate task foo`', ->
    it 'should generate a new task foo in the project', (done) ->
      run 'node', [NEAT_BIN, 'generate', 'task', 'foo'], (status) ->
        expect(inProject "src/tasks/foo.cake.coffee").toExist()

        done()

    it 'should defines the properties of the task according
        to the hash arguments provided'.squeeze(), (done) ->
      args = [
        NEAT_BIN,
        'generate',
        'task',
        'foo',
        'description:"a description"',
        'environment:production',
      ]
      run 'node', args, (status) ->
        path = inProject "src/tasks/foo.cake.coffee"
        expect(path).toContain("exports['foo'] = neatTask")
        expect(path).toContain("name: 'foo'")
        expect(path).toContain("description: 'a description'")
        expect(path).toContain("environment: 'production'")
        done()


  describe 'running `neat generate task bar/foo`', ->
    it 'should generate a new task foo in the project', (done) ->
      run 'node', [NEAT_BIN, 'generate', 'task', 'bar/foo'], (status) ->
        expect(inProject "src/tasks/bar/foo.cake.coffee").toExist()

        done()
