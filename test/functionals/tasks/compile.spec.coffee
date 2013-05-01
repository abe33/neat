require '../../test_helper'
Neat = require '../../../lib/neat'
{run} = Neat.require 'utils/commands'
{print} = require 'util'

options = {}
  # stderr: (data)-> print data
  # stdout: (data)-> print data

withBundledProject 'foo', ->

  describe 'running `cake compile`', ->
    it 'should compile the sources in the lib directory', (done) ->
      run 'node', [NEAT_BIN, 'g', 'config:packager:compile'], options, ->
        run 'cake', ['compile'], options, (status) ->
          expect(status).toBe(0)
          done()
