require '../../../test_helper'
Neat = require '../../../../lib/neat'
{run} = require '../../../../lib/utils/commands'

withProject 'foo', ->
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
