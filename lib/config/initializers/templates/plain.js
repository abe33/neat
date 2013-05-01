(function() {
  module.exports = function(config) {
    return config.engines.templates.plain = {
      render: function(tpl, context) {
        return tpl;
      }
    };
  };

}).call(this);
