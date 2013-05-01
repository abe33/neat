os = require 'os'
path = require 'path'
Neat = require '../neat'
{queue} = Neat.require 'async'
{neatTask} = Neat.require 'utils/commands'
{namespace} = Neat.require 'utils/exports'
{error, info, green, red, yellow, puts} = Neat.require 'utils/logs'
n = Neat.require 'notifications'
_ = Neat.i18n.getHelper()

notifier = switch os.platform()
  when 'darwin'
    new n.Notifier new n.plugins.Growly
  when 'linux'
    new n.Notifier new n.plugins.NotifySend

beforeTests = (test) -> (callback) ->
  Neat.task('build') (status) ->
    if status is 0 then test callback else callback? 1

runTests = (name, dir) -> (callback) ->

  statuses = []
  test = (k,f,n,d) -> (callback) ->
    f n, d, (status, result) ->
      statuses.push [status, result]
      callback? status

  actions = (test k,f,name,dir for k,f of Neat.config.engines.tests)
  queue actions, ->
    status = if statuses.some((n)-> n[0] is 1) then 1 else 0

    result = {}
    for a in statuses
      o = a[1]
      if o? then o.each (k,v) ->
        if result[k] then result[k] += v else result[k] = v

    callback? status, result

handleTestResult = (status, result, callback) ->
  if status is 0
    info green _('neat.tasks.test.tests_done')
    msg = "#{("#{v} #{k}" for k,v of result).join ', '}"
    notifier.notify
      title: _('neat.tasks.test.tests_done')
      message: msg
      success: true
    , -> callback? status


  else
    error red _('neat.tasks.test.tests_failed')
    msg = "#{("#{v} #{k}" for k,v of result).join ', '}"
    notifier.notify
      title: _('neat.tasks.test.tests_failed')
      message: msg
      success: true
    , -> callback? status

index = neatTask
  name:'test'
  description: _('neat.tasks.test.description')
  environment: 'test'
  action: beforeTests (callback) ->
    runTests('unit', 'test/units') (statusUnit, resultUnit) ->
      runTests('functional', 'test/functionals') (statusFunctional,
                                                  resultFunctional) ->
        runTests('integration', 'test/integrations') (statusIntegration,
                                                      resultIntegration) ->
          statuses = [statusUnit, statusFunctional, statusIntegration]
          status = if statuses.some((n) -> n is 1) then 1 else 0

          results = [resultUnit, resultFunctional, resultIntegration]
          result = {}
          for o in results
            if o?
              for k,v of o
                if result[k]? then result[k] += v else result[k] = v

          handleTestResult status, result, callback

unit = neatTask
  name:'test:unit'
  description: _('neat.tasks.test.unit_description')
  environment: 'test'
  action: beforeTests (callback) ->
    runTests('unit', 'test/units') (status, result) ->
      handleTestResult status, result, callback

functional = neatTask
  name:'test:functional'
  description: _('neat.tasks.test.functional_description')
  environment: 'test'
  action: beforeTests (callback) ->
    runTests('functional', 'test/functionals') (status, result) ->
      handleTestResult status, result, callback

integration = neatTask
  name:'test:integration'
  description: _('neat.tasks.test.integration_description')
  environment: 'test'
  action: beforeTests (callback) ->
    runTests('integration', 'test/integrations') (status, result) ->
      handleTestResult status, result, callback

module.exports = namespace 'test', {index, unit, functional, integration}
