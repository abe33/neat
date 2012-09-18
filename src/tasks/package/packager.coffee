Neat = require '../../neat'

{writeFile} = require 'fs'
{compile} = require 'coffee-script'
{chain} = Neat.require 'async'
{readFiles, ensure} = Neat.require 'utils/files'

LITERAL_RE = '[a-zA-Z_$][a-zA-Z0-9_$]*'
PACKAGE_RE = -> ///^(#{LITERAL_RE})(\.#{LITERAL_RE})*$///
NAME_RE = -> /^[a-zA-Z_$][a-zA-Z0-9_$-.]*$/

class Packager
  @asCommand: (conf) ->
    (callback) -> new Packager(conf).process callback

  constructor: (@conf) ->
    validate = (key, re, expect) =>
      unless re.test @conf[key]
        throw new Error "Malformed string for #{key}, expect #{expect}"

    malformedConf = (key, type) =>
      new Error "Malformed configuration for #{key}, expect #{type}"

    preventMissingConf = (key) =>
      throw new Error "Missing configuration #{key}" unless @conf[key]?

    preventMissingConf 'name'
    preventMissingConf 'package'
    preventMissingConf 'includes'
    preventMissingConf 'operators'
    malformedConf 'includes', 'Array' unless Array.isArray @conf['includes']
    malformedConf 'operators', 'Array' unless Array.isArray @conf['operators']
    validate 'name', NAME_RE(), 'a file name such foo_bar of foo-bar'
    validate 'package', PACKAGE_RE(), 'a path such com.exemple.foo'

    @conf.merge Neat.config.tasks.package
    @operators = (@conf.operatorsMap[k] for k in @conf.operators)

  process: (callback) ->
    @conf.includes = @conf.includes.map (p) -> "#{Neat.root}/#{p}.coffee"
    readFiles @conf.includes, (err, res) =>
      chain.call null, @operators, res, @conf, (buffer) =>
        @result = buffer
        callback?()

module.exports = Packager
