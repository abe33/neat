module.exports =
  Notification: require './notification'
  NotificationPlugin: require './notification_plugin'
  Notifier: require './notifier'
  plugins:
    Growly: require './plugins/growly'
    NotifySend: require './plugins/notify_send'
