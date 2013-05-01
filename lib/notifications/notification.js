(function() {
  var Notification;

  Notification = (function() {
    function Notification(title, body, success) {
      this.title = title;
      this.body = body;
      this.success = success;
    }

    return Notification;

  })();

  module.exports = Notification;

}).call(this);
