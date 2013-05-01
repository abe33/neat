
notify_send = require 'notify-send'
Neat = require '../../neat'
NotificationPlugin = Neat.require 'notifications/notification_plugin'
_ = Neat.i18n.getHelper()

class NotifySend extends NotificationPlugin
  notify: (notification, callback) ->
    if notification.success
      icon = 'res/success.png'
      label = 'success'
    else
      icon = 'res/failure.png'
      label = 'failure'

    n = notify_send.icon Neat.resolve(icon)
    n.notify notification.title, notification.message, callback

module.exports = NotifySend
