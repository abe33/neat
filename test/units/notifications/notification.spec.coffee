require '../../test_helper'

Notification = require '../../../lib/notifications/notification'

describe 'Notification', ->
  subject 'notification', -> new Notification 'title', 'body', true

  it 'should exist', ->
    expect(@notification).toBeDefined()

  it 'should contains the provided data', ->
    expect(@notification.title).toBe('title')
    expect(@notification.body).toBe('body')
    expect(@notification.success).toBeTruthy()
