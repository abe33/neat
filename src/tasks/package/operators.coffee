Neat = require '../../neat'

{writeFile} = require 'fs'
{compile:coffee} = require 'coffee-script'

LITERAL_RE = '[a-zA-Z_$][a-zA-Z0-9_$]*'
STRING_RE = '["\'][^"\']+["\']'
HASH_KEY_RE = "(#{LITERAL_RE}|#{STRING_RE})"
OBJECT_RE = "(\\s*#{HASH_KEY_RE}(\\s*:\\s*([^,\\n}]+)))+"

EXPORTS_RE = ->
  ///(?:\s|^)(module\.exports|exports)(\s*=\s*\n#{OBJECT_RE}|[=\[.\s].+\n)///gm
SPLIT_MEMBER_RE = -> /\s*=\s*/g
MEMBER_RE = -> ///\[\s*#{STRING_RE}\s*\]|\.#{LITERAL_RE}///

HASH_VALUE_RE = '(\\s*:\\s*([^,}]+))*'
HASH_RE = -> ///\{(#{HASH_KEY_RE}#{HASH_VALUE_RE},*\s*)+\}///
REQUIRE_RE = -> ///require\s*(\(\s*)*#{STRING_RE}///gm

compile = (buffer, conf, callback) ->
  for path, content of buffer
    path = path.replace('.coffee', '.js')
    buffer[path] = coffee content, bare: conf.bare

  callback?(buffer, conf)

join = (buffer, conf, callback) ->
  newBuffer = {}
  newPath = "#{conf.dir}/#{conf.name}.coffee"
  newContent = ''
  newContent += "`// #{k}`\n\n#{v}\n" for k,v of buffer
  newBuffer[newPath] = newContent

  callback?(newBuffer, conf)

stripRequires = (buffer, conf, callback) ->
  for path, content of buffer
    buffer[path] = content.split('\n')
                          .reject((s) -> REQUIRE_RE().test s)
                          .join('\n')
  callback?(buffer, conf)

exportsToPackage = (buffer, conf, callback) ->
  for path, content of buffer
    buffer[path] = "#{header conf}#{processExports content, conf}"

  callback?(buffer, conf)

header = (conf) ->
  header = ''
  packages = conf.package.split '.'
  pkg = "@#{packages.shift()}"
  header += "#{pkg} ||= {}\n"
  for p in packages
    pkg += ".#{p}"
    header += "#{pkg} ||= {}\n"

  "#{header}\n"

processExports = (content, conf) ->
  processProperty = (k,v) -> "@#{conf.package}.#{k} = #{v || k}"

  exp = []
  content = content.replace EXPORTS_RE(), (m,e,p) =>
    [member, value] = p.split SPLIT_MEMBER_RE()

    if MEMBER_RE().test member
      "@#{conf.package}#{p}"
    else
      if HASH_RE().test value
        values = value.replace(/\{|\}/g, '')
                      .strip()
                      .split(',')
                      .map((s) -> s.strip().split(/\s*:\s*/))
        exp.push processProperty k,v for [k,v] in values
      else if ///#{OBJECT_RE}///m.test value
        values = value.split('\n').map((s) -> s.strip().split(/\s*:\s*/))
        exp.push processProperty k,v for [k,v] in values
      else
        value = value.strip()
        exp.push "@#{conf.package}.#{value} = #{value}"
      ''
  "#{content}\n#{exp.join '\n'}"

module.exports = {join, compile, exportsToPackage, stripRequires}
