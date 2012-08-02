require '../../../test_helper'
Neat = require '../../../../lib/neat'
{run} = require '../../../../lib/utils/commands'

withProject 'foo', ->
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
