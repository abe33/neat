class Notifier
  constructor: (@plugin) ->
  notify: (notification) -> @plugin?.notify notification

module.exports = Notifier
