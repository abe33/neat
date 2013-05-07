require '../../test_helper'

Neat = require '../../../lib/neat'
{jasmine: Jasmine} = Neat.require 'watchers/jasmine'

describe 'Jasmine', ->
  given 'watcher', ->
    notifier:
      notify: (notification) ->

  subject 'plugin', -> new Jasmine {}, @watcher

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
  .should.supportRunAllOnStart()

  describe '::handleStatus', ->
    given 'args', -> @watcher.notifier.notify.argsForCall.last()
    beforeEach ->
      @plugin.deferred = resolve: ->

      spyOn(@watcher.notifier, 'notify').andCallThrough()

    describe 'when called with a status of 0', ->
      beforeEach -> @plugin.handleStatus 0

      it 'should have notified the success', ->
        expect(@watcher.notifier.notify).toHaveBeenCalled()
        expect(@args[0].success).toBeTruthy()

    describe 'when called with a status of 1', ->
      beforeEach -> @plugin.handleStatus 1

      it 'should have notified the success', ->
        expect(@watcher.notifier.notify).toHaveBeenCalled()
        expect(@args[0].success).toBeFalsy()

