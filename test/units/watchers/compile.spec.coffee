require '../../test_helper'
{compile: Compile} = require '../../../lib/watchers/compile'

describe 'Compile', ->
  subject 'plugin', -> new Compile

  it 'should exist', ->
    expect(@subject).toBeDefined()

  describe 'when a file watched by the plugin changed', ->
    cliRunningPlugin(Compile)
    .should.run('cake', 'build')
    .should.storeProcessAndKillIt()
    .should.bePendingUntilEnd()
