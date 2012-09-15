op = require '../../../tasks/package/operators'

module.exports = (config) ->
  config.tasks.package.merge
    operatorsMap:
      'annotate:class': op.annotateClass
      'annotate:file': op.annotateFile
      'join': op.join
      'compile': op.compile
      'strip:requires': op.stripRequires
      'exports:package': op.exportsToPackage
      'saveToFile': op.saveToFile
