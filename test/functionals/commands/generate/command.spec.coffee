require '../../../test_helper'
Neat = require '../../../../lib/neat'
{run} = require '../../../../lib/utils/commands'
{print} = require 'util'

options = {}
  # stderr: (data)-> print data
  # stdout: (data)-> print data

testSimpleGenerator 'command', 'src/commands', '.cmd.coffee'

withProject 'neat_project', ->
  describe 'running `neat generate command foo`', ->
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
