Neat = require '../../neat'

{writeFile} = require 'fs'
{readFiles, ensure} = Neat.require 'utils/files'
{compile} = require 'coffee-script'

LITERAL_RE = '[a-zA-Z_$][a-zA-Z0-9_$]*'
STRING_RE = '["\'][^"\']+["\']'
HASH_KEY_RE = "(#{LITERAL_RE}|#{STRING_RE})"
OBJECT_RE = "(\\s*#{HASH_KEY_RE}(\\s*:\\s*([^,\\n}]+)))+"

PACKAGE_RE = -> ///^(#{LITERAL_RE})(\.#{LITERAL_RE})*$///
NAME_RE = -> /^[a-zA-Z_$][a-zA-Z0-9_$-]*$/
EXPORTS_RE = ->
  ///(?:\s|^)(module\.exports|exports)(\s*=\s*\n#{OBJECT_RE}|[=\[.\s].+\n)///gm
SPLIT_MEMBER_RE = -> /\s*=\s*/g
MEMBER_RE = -> ///\[\s*#{STRING_RE}\s*\]|\.#{LITERAL_RE}///

HASH_VALUE_RE = '(\\s*:\\s*([^,}]+))*'
HASH_RE = -> ///\{(#{HASH_KEY_RE}#{HASH_VALUE_RE},*\s*)+\}///
REQUIRE_RE = -> ///(^|([^=]+=\s*)*)require\s*#{STRING_RE}\s*///gm

class Packager
  @asCommand: (conf) -> (callback) -> new Packager(conf).process callback

  constructor: (@conf) ->
    validate = (key, re, expect) =>
      unless re.test @conf[key]
        throw new Error "Malformed string for #{key}, expect #{expect}"

    malformedConf = (key, type) =>
      new Error "Malformed configuration for #{key}, expect #{type}"

    preventMissingConf = (key) =>
      throw new Error "Missing configuration #{key}" unless @conf[key]?

    preventMissingConf 'name'
    preventMissingConf 'includes'
    malformedConf 'includes', 'Array' unless Array.isArray @conf['includes']
    validate 'name', NAME_RE(), 'a file name such foo_bar of foo-bar'
    validate 'package', PACKAGE_RE(), 'a path such com.exemple.foo'

  process: (callback) ->
    {tmp} = Neat.config.tasks.package
    files = @conf.includes.map (p) -> "#{Neat.root}/#{p}.coffee"
    readFiles files, (err, res) =>
      content = @header()
      content += @processFile k,v for k,v of res
      @result = @processExports content
      @js = compile @result, bare: @conf.bare
      writeFile "#{tmp}/#{@conf.name}.coffee", @result, (err) =>
        writeFile "#{tmp}/#{@conf.name}.js", @js, (err) -> callback?()

  processFile: (k,v) -> "`// #{k}`\n\n#{@stripRequires v}\n"

  processExports: (content) ->
    exp = []
    content = content.replace EXPORTS_RE(), (m,e,p) =>
      [member, value] = p.split SPLIT_MEMBER_RE()

      if MEMBER_RE().test member
        "@#{@conf.package}#{p}"
      else
        if HASH_RE().test value
          values = value.replace(/\{|\}/g, '')
                        .strip()
                        .split(',')
                        .map((s) -> s.strip().split(/\s*:\s*/))
          exp.push @processProperty k,v for [k,v] in values
        else if ///#{OBJECT_RE}///m.test value
          values = value.split('\n').map((s) -> s.strip().split(/\s*:\s*/))
          exp.push @processProperty k,v for [k,v] in values
        else
          value = value.strip()
          exp.push "@#{@conf.package}.#{value} = #{value}"
        ''

    "#{content}\n#{exp.join '\n'}"

  processProperty: (k,v) ->
    v = k unless v?
    "@#{@conf.package}.#{k} = #{v}"

  stripRequires: (content) ->
    content.split('\n').reject((s) -> s.indexOf('require') isnt -1).join('\n')

  header: () ->
    header = ''
    packages = @conf.package.split '.'
    pkg = "@#{packages.shift()}"
    header += "#{pkg} ||= {}\n"
    for p in packages
      pkg += ".#{p}"
      header += "#{pkg} ||= {}\n"

    "#{header}\n"

module.exports = Packager
