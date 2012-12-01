glob = require 'glob'
{compile} = require 'coffee-script'
{writeFile} = require 'fs'
{resolve} = require 'path'

Neat = require '../../neat'
{chain, parallel} = Neat.require 'async'
{readFiles, ensure} = Neat.require 'utils/files'
_ = Neat.i18n.getHelper()

class Packager
  @asCommand: (conf) ->
    (callback) -> new Packager(conf).process callback

  constructor: (@conf) ->
    malformedConf = (key, type) =>
      throw new Error _ 'neat.tasks.package.invalid_configuration', {key, type}

    preventMissingConf = (key) =>
      unless @conf[key]?
        throw new Error _ 'neat.tasks.package.missing_configuration', {key}

    preventMissingConf 'includes'
    preventMissingConf 'operators'
    malformedConf 'includes', 'Array' unless Array.isArray @conf['includes']
    malformedConf 'operators', 'Array' unless Array.isArray @conf['operators']

    @conf.merge Neat.config.tasks.package
    @operators = (@conf.operatorsMap[k] for k in @conf.operators)
    operator.validate? @conf for operator in @operators

  process: (callback) ->
    @find @conf.includes, (err, files) =>
      @conf.files = files
      readFiles files, (err, res) =>
        chain.call null, @operators, res, @conf, (buffer) =>
          @result = buffer
          callback?()

  find: (paths, callback) ->
    files = []
    f = (p) -> (cb) ->
      if p.indexOf('*') is -1
        p = resolve Neat.root, "#{p}.coffee"
        return cb files.push p
      else
        glob p, {}, (err, fs) ->
          files = files.concat fs
          cb()

    parallel (f p for p in paths), ->
      callback null, files.map (f) -> resolve Neat.root, f


module.exports = Packager
