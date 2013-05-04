require '../test_helper'

Neat = require '../../lib/neat'
{logger} = Neat.require 'utils/logs'

describe 'Neat', ->
  beforeEach ->
    spyOn(logger, 'log').andCallFake ->

  it 'should exist', ->
    expect(Neat).toBeDefined()


  describe '::initLogging', ->
    beforeEach ->
      Neat.config =
        defaultLoggingEngine: 'foo'
        engines:
          logging:
            foo: ->

      spyOn(logger, 'add').andCallFake ->

    it 'should have registered a listener', ->
      Neat.initLogging()

      expect(logger.add).toHaveBeenCalled()

  describe '::initEnvironment', ->
    beforeEach ->
      spyOn(logger, 'add').andCallFake ->
      spyOn(Neat.beforeEnvironment, 'dispatch').andCallThrough()
      spyOn(Neat.afterEnvironment, 'dispatch').andCallThrough()
      spyOn(Neat.beforeInitialize, 'dispatch').andCallThrough()
      spyOn(Neat.afterInitialize, 'dispatch').andCallThrough()

    it 'should have initialized the logger', (done) ->
      Neat.initEnvironment ->
        expect(logger.add).toHaveBeenCalled()
        done()

    it 'should set the environment', (done) ->
      Neat.initEnvironment ->
        expect(Neat.env).toEqual('default')
        expect(Neat.env.default).toBeDefined()
        done()

    it 'should have triggered hooks', ->
      Neat.initEnvironment ->
        expect(Neat.beforeEnvironment.dispatch).toHaveBeenCalled()
        expect(Neat.afterEnvironment.dispatch).toHaveBeenCalled()
        expect(Neat.beforeInitialize.dispatch).toHaveBeenCalled()
        expect(Neat.afterInitialize.dispatch).toHaveBeenCalled()

    it 'should have created the config object', ->
      Neat.initEnvironment ->
        expect(Neat.config).toBeDefined()
        expect(Neat.CONFIG).toBeDefined()


