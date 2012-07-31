require '../../test_helper'
Neat = require '../../../lib/neat'
{run} = require '../../../lib/utils/commands'

withProject 'foo', ->
  afterEach ->
    run 'rm', ['-rf', @projectPath]

  describe 'running `neat install`', ->
    it 'should install the dependencies', ->
      runs ->
        ended = false
        run 'node', [NEAT_BIN, 'install'], (status) ->
          expect(status).toBe(0)
          expect(inProject 'node_modules/neat').toExist()
          ended = true

        waitsFor progress(-> ended), 'Timed out', 50000
, noCleaning: true
