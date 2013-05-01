(function() {
  var Neat, NotificationPlugin, NotifySend, notify_send, _, _ref,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  notify_send = require('notify-send');

  Neat = require('../../neat');

  NotificationPlugin = Neat.require('notifications/notification_plugin');

  _ = Neat.i18n.getHelper();

  NotifySend = (function(_super) {
    __extends(NotifySend, _super);

    function NotifySend() {
      _ref = NotifySend.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    NotifySend.prototype.notify = function(notification, callback) {
      var icon, label, n;

      if (notification.success) {
        icon = 'res/success.png';
        label = 'success';
      } else {
        icon = 'res/failure.png';
        label = 'failure';
      }
      n = notify_send.icon(Neat.resolve(icon));
      return n.notify(notification.title, notification.message, callback);
    };

    return NotifySend;

  })(NotificationPlugin);

  module.exports = NotifySend;

}).call(this);
