require '../../../test_helper'

growly = require 'growly'
Neat = require '../../../../lib/neat'
Growly = Neat.require 'notifications/plugins/growly'

describe 'Growly', ->
  beforeEach ->
    spyOn(growly, 'register').andCallFake ->
    spyOn(growly, 'notify').andCallFake (msg, opts, cb) -> cb?()

  subject 'growlyPlugin', -> new Growly

  it 'should exist', ->
    expect(@growlyPlugin).toBeDefined()

  describe 'when created', ->
    it 'should have registered Neat as an application', ->
      @growlyPlugin

      expect(growly.register).toHaveBeenCalledWith(
        'Neat',
        Neat.resolve('res/success.png'),
        [
          {label: 'success', dispname: 'Success'}
          {label: 'failure', dispname: 'Failure'}
        ]
      )

  describe '::notify', ->
    describe 'when called with a success notification', ->
      given 'notification', ->
        title: 'title'
        message: 'message'
        success: true
      given 'notificationListener', -> ->

      subject 'notify', ->
        @growlyPlugin.notify @notification, @notificationListener


      it 'should have called the growly notify method', ->
        @notify
        expect(growly.notify)
        .toHaveBeenCalledWith(
          'message',
          {
            icon: Neat.resolve('res/success.png')
            title: 'title'
            label: 'success'
          },
          @notificationListener
        )

    describe 'when called with a failure notification', ->
      given 'notification', ->
        title: 'title'
        message: 'message'
        success: false
      given 'notificationListener', -> ->

      subject 'notify', ->
        @growlyPlugin.notify @notification, @notificationListener


      it 'should have called the growly notify method', ->
        @notify
        expect(growly.notify)
        .toHaveBeenCalledWith(
          'message',
          {
            icon: Neat.resolve('res/failure.png')
            title: 'title'
            label: 'failure'
          },
          @notificationListener
        )


