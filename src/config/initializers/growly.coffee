growly = require 'growly'
module.exports = (config) ->
  growly.register 'Neat', 'res/success.png', [
    label: 'success', dispname: 'Success'
    label: 'failure', dispname: 'Failure'
  ]
