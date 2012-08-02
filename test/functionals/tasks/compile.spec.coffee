require '../../test_helper'
Neat = require '../../../lib/neat'
{run} = require '../../../lib/utils/commands'

withBundledProject 'foo', ->
  describe 'running `cake compile`', ->
    it 'should compile the sources in the lib directory', (done) ->
      run 'cake', ['compile'], (status) ->
        expect(status).toBe(0)
        expect(inProject 'lib/config/initializers/commands/docco.js')
          .toExist()
        done()
