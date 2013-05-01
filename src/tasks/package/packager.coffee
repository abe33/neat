glob = require 'glob'
{compile} = require 'coffee-script'
{writeFile} = require 'fs'
{resolve, basename, extname} = require 'path'

Neat = require '../../neat'
{chain, parallel} = Neat.require 'async'
{readFiles, ensure} = Neat.require 'utils/files'
{green, yellow, red, print, puts} = Neat.require 'utils/logs'
_ = Neat.i18n.getHelper()

class Packager
  @asCommand: (conf, path) ->
    (callback) -> new Packager(conf, path).process callback

  constructor: (@conf, @path) ->
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
        errCallback = (err) =>
          puts yellow(_ 'neat.tasks.package.process', file: basename @path), 5
          stack = err.stack.split '\n'
          stack[0] = red stack[0]
          puts "#{stack.join '\n'}\n", 5
          callback? 1

        chain.call null, @operators, res, @conf, errCallback, (buffer) =>
          @result = buffer
          puts """
            #{yellow(_ 'neat.tasks.package.process', file: basename @path)}
            #{(green('.') for k of @result).join ''}
            #{green(_ 'neat.tasks.package.processed', files: @result.length())}

          """, 5

          callback? 0

  find: (paths, callback) ->
    files = []
    f = (p) -> (cb) ->
      p = "#{p}.coffee" if extname(p) is ''
      glob resolve(Neat.root, p), {}, (err, fs) ->
        files = files.concat fs
        cb()

    parallel (f p for p in paths), ->
      callback null, files.uniq().map (f) -> resolve Neat.root, f


module.exports = Packager
