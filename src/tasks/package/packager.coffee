Neat = require '../../neat'

{writeFile} = require 'fs'
{compile} = require 'coffee-script'
{chain} = Neat.require 'async'
{readFiles, ensure} = Neat.require 'utils/files'
_ = Neat.i18n.getHelper()

NAME_RE = -> /^[a-zA-Z_$][a-zA-Z0-9_$-.]*$/

class Packager
  @asCommand: (conf) ->
    (callback) -> new Packager(conf).process callback

  constructor: (@conf) ->
    validate = (key, re, expect) =>
      unless re.test @conf[key]
        throw new Error _ 'neat.tasks.package.invalid_string', {key, expect}

    malformedConf = (key, type) =>
      throw new Error _ 'neat.tasks.package.invalid_configuration', {key, type}

    preventMissingConf = (key) =>
      throw new Error _('neat.tasks.package.missing_configuration',
                        {key}) unless @conf[key]?

    preventMissingConf 'name'
    preventMissingConf 'includes'
    preventMissingConf 'operators'
    malformedConf 'includes', 'Array' unless Array.isArray @conf['includes']
    malformedConf 'operators', 'Array' unless Array.isArray @conf['operators']
    validate 'name', NAME_RE(), _('neat.tasks.package.expected_name')

    @conf.merge Neat.config.tasks.package
    @operators = (@conf.operatorsMap[k] for k in @conf.operators)
    operator.validate? @conf for operator in @operators

  process: (callback) ->
    @conf.includes = @conf.includes.map (p) -> "#{Neat.root}/#{p}.coffee"
    readFiles @conf.includes, (err, res) =>
      chain.call null, @operators, res, @conf, (buffer) =>
        @result = buffer
        callback?()

module.exports = Packager
