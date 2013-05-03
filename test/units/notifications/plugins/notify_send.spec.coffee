require '../../../test_helper'

notify_send = require 'notify-send'
Neat = require '../../../../lib/neat'
NotifySend = Neat.require 'notifications/plugins/notify_send'

describe 'NotifySend', ->
  beforeEach ->
    spyOn(notify_send, 'icon').andCallThrough()
    spyOn(notify_send, 'notify').andCallFake (msg, opts, cb) -> cb?()

  subject 'nsPlugin', -> new NotifySend

  it 'should exist', ->
    expect(@nsPlugin).toBeDefined()

  describe '::notify', ->
    describe 'when called with a success notification', ->
      given 'notification', ->
        title: 'title'
        message: 'message'
        success: true
      given 'notificationListener', -> ->

      subject 'notify', ->
        @nsPlugin.notify @notification, @notificationListener


      it 'should have called the notify_send notify method', ->
        @notify
        expect(notify_send.icon)
        .toHaveBeenCalledWith(Neat.resolve('res/success.png'))

        expect(notify_send.notify)
        .toHaveBeenCalledWith('title', 'message', @notificationListener)

    describe 'when called with a failure notification', ->
      given 'notification', ->
        title: 'title'
        message: 'message'
        success: false
      given 'notificationListener', -> ->

      subject 'notify', ->
        @nsPlugin.notify @notification, @notificationListener


      it 'should have called the notify_send notify method', ->
        @notify

        expect(notify_send.icon)
        .toHaveBeenCalledWith(Neat.resolve('res/failure.png'))

        expect(notify_send.notify)
        .toHaveBeenCalledWith('title', 'message', @notificationListener)

