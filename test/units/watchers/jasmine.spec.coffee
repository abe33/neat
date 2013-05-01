require '../../test_helper'

Neat = require '../../../lib/neat'
{jasmine: Jasmine} = Neat.require 'watchers/jasmine'

describe 'Jasmine', ->
  subject 'plugin', -> new Jasmine

  it 'should exist', ->
    expect(@plugin).toBeDefined()

  cliRunningPlugin(Jasmine)
  .withChangedPath('src/core/types/object.coffee')
  .should.run(Neat.resolve('node_modules/.bin/jasmine-node'),
              '--coffee',
              Neat.resolve('src/core/types/object.coffee'))
  .should.storeProcessAndKillIt()
  .should.bePendingUntilEnd()
  .should.runAllWith(Neat.resolve('node_modules/.bin/jasmine-node'),
                    '--coffee', Neat.resolve('test'))
