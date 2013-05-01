(function() {
  var Notifier;

  Notifier = (function() {
    function Notifier(plugin) {
      this.plugin = plugin;
    }

    Notifier.prototype.notify = function(notification, callback) {
      var _ref;

      return (_ref = this.plugin) != null ? _ref.notify(notification, callback) : void 0;
    };

    return Notifier;

  })();

  module.exports = Notifier;

}).call(this);
