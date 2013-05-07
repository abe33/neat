require '../../test_helper'
Neat = require '../../../lib/neat'
{lint: Lint} = Neat.require 'watchers/lint'

describe 'Lint', ->
  given 'watcher', ->
    notifier:
      notify: (notification) ->

  subject 'plugin',  -> new Lint {}, @watcher

  it 'should exist', ->
    expect(@subject).toBeDefined()

  describe 'when a file watched by the plugin changed', ->
    cliRunningPlugin(Lint)
    .should.run(Neat.resolve('node_modules/.bin/coffeelint'),
                '-f',
                Neat.resolve('config/tasks/lint.json'),
                Neat.resolve('src/neat.coffee'))
    .should.storeProcessAndKillIt()
    .should.bePendingUntilEnd()
    .should.runAllWith('cake', 'lint')
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


