require '../../test_helper'
Neat = require '../../../lib/neat'
{lint: Lint} = Neat.require 'watchers/lint'

describe 'Lint', ->
  subject 'plugin',  -> new Lint

  it 'should exist', ->
    expect(@subject).toBeDefined()

  describe 'when a file watched by the plugin changed', ->
    cliRunningPlugin(Lint)
    .should.run(Neat.resolve('node_modules/.bin/coffeelint'),
                Neat.resolve('src/neat.coffee'))
    .should.storeProcessAndKillIt()
    .should.bePendingUntilEnd()
    .should.runAllWith('cake', 'lint')
