(function() {
  var Growly, Neat, NotificationPlugin, growly, _,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  growly = require('growly');

  Neat = require('../../neat');

  NotificationPlugin = Neat.require('notifications/notification_plugin');

  _ = Neat.i18n.getHelper();

  Growly = (function(_super) {
    __extends(Growly, _super);

    function Growly() {
      growly.register('Neat', Neat.resolve('res/success.png'), [
        {
          label: 'success',
          dispname: 'Success'
        }, {
          label: 'failure',
          dispname: 'Failure'
        }
      ]);
    }

    Growly.prototype.notify = function(notification, callback) {
      var icon, label;

      if (notification.success) {
        icon = Neat.resolve('res/success.png');
        label = 'success';
      } else {
        icon = Neat.resolve('res/failure.png');
        label = 'failure';
      }
      return growly.notify(notification.message, {
        icon: Neat.resolve(icon),
        title: notification.title,
        label: label
      }, callback);
    };

    return Growly;

  })(NotificationPlugin);

  module.exports = Growly;

}).call(this);
