require '../../test_helper'

Notifier = require '../../../lib/notifications/notifier'
Notification = require '../../../lib/notifications/notification'

describe 'Notifier', ->
  subject 'notifier', -> new Notifier

  it 'should exist', ->
    expect(@notifier).toBeDefined()

  describe 'when constructed with a plugin', ->
    given 'plugin', -> new MockNotificationPlugin
    subject 'notifier', -> new Notifier @plugin

    describe '::notify', ->
      describe 'called with a notification', ->
        given 'notification', -> new Notification 'title', 'body', true
        beforeEach -> @notifier.notify @notification

        it 'should have called the plugin notify method', ->
          expect(@plugin.notify.called).toBeTruthy()



