
NotificationPlugin = require '../../../lib/notifications/notification_plugin'

class MockNotificationPlugin extends NotificationPlugin
  constructor: ->
    for k,v of this
      if typeof v is 'function'
        @[k] = f = =>
          f.called = true
          f.arguments = arguments
          v.apply this, arguments

global.MockNotificationPlugin = MockNotificationPlugin
