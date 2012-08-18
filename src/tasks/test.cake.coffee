path = require 'path'
Neat = require '../neat'
{queue} = require '../async'
{neatTask} = require '../utils/commands'
{namespace} = require '../utils/exports'
{error, info, green, red, yellow, puts} = require '../utils/logs'

test = (k,f,n,d) -> (callback) -> f n, d, -> callback?()

beforeTests = (test) -> (callback) ->
  Neat.task('compile') (status) ->
    if status is 0 then test callback else callback?()

runTests = (name, dir) -> (callback) ->
  actions = (test k,f,name,dir for k,f of Neat.config.engines.tests)
  queue actions, -> callback?()

index = neatTask
  name:'test'
  description: 'Run all tests'
  environment: 'test'
  action: beforeTests (callback) ->
    runTests('unit', 'test/units') (status) ->
      runTests('functional', 'test/functionals') (status) ->
        info green 'All tests complete'
        callback?()

unit = neatTask
  name:'test:unit'
  description: 'Run unit tests'
  environment: 'test'
  action: beforeTests (callback) ->
    runTests('unit', 'test/units') ->
      info green 'All tests complete'
      callback?()

functional = neatTask
  name:'test:functional'
  description: 'Run functional tests'
  environment: 'test'
  action: beforeTests (callback) ->
    runTests('functional', 'test/functionals') ->
      info green 'All tests complete'
      callback?()

module.exports = namespace 'test', {index, unit, functional}
