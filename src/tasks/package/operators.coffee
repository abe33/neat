Neat = require '../../neat'

{parallel} = Neat.require 'async'
{writeFile} = require 'fs'
{compile:coffee} = require 'coffee-script'
{parser, uglify:pro} = require 'uglify-js'

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

CLASS_RE = -> ///^[^#]*class\s*(#{LITERAL_RE})///
CLASS_MEMBER_RE = ->
  ///
    ^
    (\s+)               # Indent
    (#{LITERAL_RE})     # Member name
    \s*:\s*             # :
    (\([^)]+\)\s*)*->   # Function
  ///

STATIC_MEMBER_RE = ->
  ///
    ^
    (\s+)               # Indent
    @(#{LITERAL_RE})    # Member name
    \s*:\s*             # :
    (\([^)]+\)\s*)*->   # Function
  ///

analyze = (path, content) ->
  out = content.concat()
  i2 = 0
  curClass = null
  for line,i in content
    comment = null
    if CLASS_RE().test line
      [m,curClass] = CLASS_RE().exec line
      comment = "`/* #{cleanPath path}<#{curClass}> line:#{i+1} */`"

    if CLASS_MEMBER_RE().test line
      [m,s,p] = CLASS_MEMBER_RE().exec line
      comment = "#{s}`/* #{cleanPath path}<#{curClass}::#{p}> line:#{i+1} */`"

    if STATIC_MEMBER_RE().test line
      [m,s,p] = STATIC_MEMBER_RE().exec line
      comment = "#{s}`/* #{cleanPath path}<#{curClass}.#{p}> line:#{i+1} */`"

    if comment?
      out.splice i2, 0, comment
      i2++

    i2++
  out

annotateClass = (buffer, conf, callback) ->
  for path, content of buffer
    content = content.split('\n')
    content = analyze path, content
    buffer[path] = content.join('\n')
  callback?(buffer, conf)

annotateFile = (buffer, conf, callback) ->
  for p, content of buffer
    buffer[p] = "`/* #{cleanPath p} */`\n\n#{content}\n"

  callback?(buffer, conf)

cleanPath = (path) ->
  path.replace "#{Neat.root}/", ''

compile = (buffer, conf, callback) ->
  newBuffer = {}
  for path, content of buffer
    path = path.replace('.coffee', '.js')
    newBuffer[path] = coffee content, bare: conf.bare

  callback?(newBuffer, conf)

exportsToPackage = (buffer, conf, callback) ->
  header = (conf) ->
    header = ''
    packages = conf.package.split '.'
    pkg = "@#{packages.shift()}"
    header += "#{pkg} ||= {}\n"
    for p in packages
      pkg += ".#{p}"
      header += "#{pkg} ||= {}\n"

    "#{header}\n"

  convertExports = (content, conf) ->
    packageFor = (k,v) -> "@#{conf.package}.#{k} = #{v || k}"

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
          exp.push packageFor k,v for [k,v] in values
        else if ///#{OBJECT_RE}///m.test value
          values = value.split('\n').map((s) -> s.strip().split(/\s*:\s*/))
          exp.push packageFor k,v for [k,v] in values
        else
          value = value.strip()
          exp.push "@#{conf.package}.#{value} = #{value}"
        ''
    "#{content}\n#{exp.join '\n'}"

  for path, content of buffer
    buffer[path] = "#{header conf}#{convertExports content, conf}"

  callback?(buffer, conf)


join = (buffer, conf, callback) ->
  newBuffer = {}
  newPath = "#{conf.dir}/#{conf.name}.coffee"
  newContent = ''
  newContent += buffer[k] for k in conf.includes
  newBuffer[newPath] = newContent

  callback?(newBuffer, conf)

uglify = (buffer, conf, callback) ->
  for path, content of buffer
    ast = parser.parse(content)
    ast = pro.ast_mangle(ast)
    ast = pro.ast_squeeze(ast)
    buffer[path] = pro.gen_code(ast)

  callback?(buffer, conf)

saveToFile = (buffer, conf, callback) ->
  gen = (path, content) -> (callback) ->
    writeFile path, content, ->
      callback?()

  parallel (gen k,v for k,v of buffer), ->
    callback?(buffer, conf)

stripRequires = (buffer, conf, callback) ->
  for path, content of buffer
    buffer[path] = content.split('\n')
                          .reject((s) -> REQUIRE_RE().test s)
                          .join('\n')
  callback?(buffer, conf)

module.exports = {
  annotateClass
  annotateFile
  compile
  exportsToPackage
  join
  uglify
  saveToFile
  stripRequires
}
