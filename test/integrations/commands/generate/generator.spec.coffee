require '../../../test_helper'
Neat = require '../../../../lib/neat'
{run} = require '../../../../lib/utils/commands'

withProject 'foo', ->
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
