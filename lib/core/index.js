(function() {

  require('./types');

  module.exports = {
    Module: require('./module'),
    Mixin: require('./mixin'),
    Signal: require('./signal')
  };

}).call(this);
