require '../../test_helper'

describe 'NotificationPlugin', ->
  subject -> new NotificationPlugin

  it 'should exist', ->
    expect(@subject).toBeDefined()
