(function() {
  var growly;

  growly = require('growly');

  module.exports = function(config) {
    return growly.register('Neat', 'res/success.png', [
      {
        label: 'success',
        dispname: 'Success'
      }, {
        label: 'failure',
        dispname: 'Failure'
      }
    ]);
  };

}).call(this);
