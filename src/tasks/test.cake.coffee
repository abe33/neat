path = require 'path'
Neat = require '../neat'
{queue} = Neat.require 'async'
{neatTask} = Neat.require 'utils/commands'
{namespace} = Neat.require 'utils/exports'
{error, info, green, red, yellow, puts} = Neat.require 'utils/logs'
_ = Neat.i18n.getHelper()


beforeTests = (test) -> (callback) ->
  Neat.task('compile') (status) ->
    if status is 0 then test callback else callback? 1

runTests = (name, dir) -> (callback) ->
  statuses = []
  test = (k,f,n,d) -> (callback) ->
    f n, d, (status) ->
      statuses.push status
      callback? status
  actions = (test k,f,name,dir for k,f of Neat.config.engines.tests)
  queue actions, ->
    status = if statuses.some((n)-> n is 1) then 1 else 0
    callback? status

index = neatTask
  name:'test'
  description: _('neat.tasks.test.description')
  environment: 'test'
  action: beforeTests (callback) ->
    runTests('unit', 'test/units') (statusUnit) ->
      runTests('functional', 'test/functionals') (statusFunctional) ->
        statuses = [statusUnit, statusFunctional]
        status = if statuses.some((n) -> n is 1) then 1 else 0
        if status is 0
          info green _('neat.tasks.test.tests_done')
        else
          error red _('neat.tasks.test.tests_failed')
        callback? status

unit = neatTask
  name:'test:unit'
  description: _('neat.tasks.test.unit_description')
  environment: 'test'
  action: beforeTests (callback) ->
    runTests('unit', 'test/units') (status) ->
      if status is 0
        info green _('neat.tasks.test.tests_done')
      else
        error red _('neat.tasks.test.tests_failed')
      callback? status

functional = neatTask
  name:'test:functional'
  description: _('neat.tasks.test.functional_description')
  environment: 'test'
  action: beforeTests (callback) ->
    runTests('functional', 'test/functionals') (status) ->
      if status is 0
        info green _('neat.tasks.test.tests_done')
      else
        error red _('neat.tasks.test.tests_failed')
      callback? status

module.exports = namespace 'test', {index, unit, functional}
