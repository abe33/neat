require '../../test_helper'

NotificationPlugin = require '../../../lib/notifications/notification_plugin'

describe 'NotificationPlugin', ->
  subject -> new NotificationPlugin

  it 'should exist', ->
    expect(@subject).toBeDefined()
