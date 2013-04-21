require '../../test_helper'
Neat = require '../../../lib/neat'
{nemfile: Nemfile} = Neat.require 'watchers/nemfile'

describe 'Nemfile', ->
  subject 'plugin', -> new Nemfile

  it 'should exist', ->
    expect(@plugin).toBeDefined()

  describe 'when a file watched by the plugin changed', ->
    cliRunningPlugin(Nemfile)
    .should.run('neat', 'install')
    .should.storeProcessAndKillIt()
    .should.bePendingUntilEnd()
