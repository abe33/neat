require '../../../test_helper'

Logger = require '../../../../lib/utils/logs/logger'

describe 'Logger', ->
  subject 'logger', -> new Logger

  it 'should exist', ->
    expect(@logger).toBeDefined()

  describe '::add', ->
    it 'should add a listener to the logger', ->
      expect(@logger.logged.listeners.length).toBe(0)

      @logger.add ->

      expect(@logger.logged.listeners.length).toBe(1)

  describe '::remove', ->
    it 'should add a listener to the logger', ->
      listener = ->

      @logger.add listener, this

      expect(@logger.logged.listeners.length).toBe(1)

      @logger.remove listener, this

      expect(@logger.logged.listeners.length).toBe(0)

  describe '::log', ->
    it 'should send a signal', ->
      signalCalled = false
      @logger.add -> signalCalled = true

      @logger.log "message"

      expect(signalCalled).toBeTruthy()
