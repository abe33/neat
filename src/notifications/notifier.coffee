class Notifier
  constructor: (@plugin) ->
  notify: (notification, callback) -> @plugin?.notify notification, callback

module.exports = Notifier
