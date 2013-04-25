
growly = require 'growly'
Neat = require '../../neat'
NotificationPlugin = Neat.require 'notifications/notification_plugin'
_ = Neat.i18n.getHelper()

class Growly extends NotificationPlugin
  constructor: ->
    growly.register 'Neat', Neat.resolve('res/success.png'), [
      {label: 'success', dispname: 'Success'}
      {label: 'failure', dispname: 'Failure'}
    ]

  notify: (notification, callback) ->
    if notification.success
      icon = Neat.resolve('res/success.png')
      label = 'success'
    else
      icon = Neat.resolve('res/failure.png')
      label = 'failure'

    growly.notify notification.message, {
      icon: Neat.resolve(icon),
      title: notification.title
      label: label
    }, callback

module.exports = Growly
