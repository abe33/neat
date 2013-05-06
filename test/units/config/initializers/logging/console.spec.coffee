require '../../../../test_helper'

util = require 'util'

Neat = require '../../../../../lib/neat'
consoleLogger = Neat.require 'config/initializers/logging/console'

describe 'console logger initializer', ->
  it 'should exists', ->
    expect(consoleLogger).toBeDefined()

  describe 'when called', ->
    given 'config', ->
      verbosity: 1
      engines: { logging: {} }

    beforeEach ->
      spyOn(util, 'print').andCallFake ->
      consoleLogger @config

    it 'should have registered the logging backend', ->
      expect(@config.engines.logging.console).toBeDefined()

    describe 'the registered backend', ->
      given 'backend', ->
        @config.engines.logging.console

      describe 'when log level is 1', ->
        it 'should have print the log', ->
          @backend null, message: 'irrelevant', level: 1
          expect(util.print).toHaveBeenCalled()

      describe 'when log level is 0', ->

        it 'should not have print the log', ->
          @backend null, message: 'irrelevant', level: 0
          expect(util.print).not.toHaveBeenCalled()
