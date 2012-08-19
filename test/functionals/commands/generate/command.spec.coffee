require '../../../test_helper'
Neat = require '../../../../lib/neat'
{run} = require '../../../../lib/utils/commands'
{print} = require 'util'

options = {}
  # stderr: (data)-> print data
  # stdout: (data)-> print data

describe 'when outside a project', ->
  beforeEach -> process.chdir FIXTURES_ROOT

  describe 'running `neat generate command foo`', ->
    it "should return a status of 1 and don't generate anything", ->
      ended = false
      runs ->
        args = [NEAT_BIN, 'generate', 'command', 'foo']
        run 'node', args, options, (status) ->
          expect(status).toBe(1)
          ended = true

      waitsFor progress(-> ended), 'Timed out', 10000

withProject 'foo', ->
  describe 'running `neat generate command`', ->
    it "should return a status of 1 and don't generate anything", ->
      ended = false
      runs ->
        run 'node', [NEAT_BIN, 'generate', 'command'], options, (status) ->
          expect(status).toBe(1)
          ended = true

      waitsFor progress(-> ended), 'Timed out', 10000

  describe 'running `neat generate command foo`', ->
    it 'should generate a new command foo in the project', (done) ->
      args = [
        NEAT_BIN,
        'generate',
        'command',
        'foo',
      ]
      run 'node', args, (status) ->
        expect(inProject "src/commands/foo.cmd.coffee").toExist()

        done()

    it 'should defines the properties of the command according
        to the hash arguments provided'.squeeze(), (done) ->
      args = [
        NEAT_BIN,
        'generate',
        'command',
        'foo',
        'description:"a description"',
        'usages:foo,bar,baz',
        'environment:production',
      ]
      run 'node', args, (status) ->
        path = inProject "src/commands/foo.cmd.coffee"
        expect(path).toContain("foo = (pr) ->")
        expect(path).toContain("module.exports = {foo}")
        expect(path).toContain("aliases 'foo',")
        expect(path).toContain("describe 'a description',")
        expect(path).toContain("usages 'foo', 'bar', 'baz',")
        expect(path).toContain("environment 'production',")
        expect(path).toContain("cmd = (args..., callback) ->")
        done()

    it 'should defines the usage even when there is only one
        provided'.squeeze(), (done) ->
      args = [
        NEAT_BIN,
        'generate',
        'command',
        'foo',
        'usages:foo',
      ]
      run 'node', args, (status) ->
        expect(inProject "src/commands/foo.cmd.coffee")
          .toContain("usages 'foo',")
        done()

  describe 'running `neat generate command bar/foo`', ->
    it 'should generate a new command foo in the project', (done) ->
      run 'node', [NEAT_BIN, 'generate', 'command', 'bar/foo'], (status) =>
        expect(inProject "src/commands/bar/foo.cmd.coffee").toExist()

        done()
