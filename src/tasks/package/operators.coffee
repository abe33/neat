{resolve} = require 'path'
{writeFile} = require 'fs'

Neat = require '../../neat'
{parallel} = Neat.require 'async'
{ensurePath, rm, ensurePath} = Neat.require 'utils/files'
{compile:coffee} = require 'coffee-script'
{parser, uglify:pro} = require 'uglify-js'
_ = Neat.i18n.getHelper()

LITERAL_RE = '[a-zA-Z_$][a-zA-Z0-9_$]*'
STRING_RE = '["\'][^"\']+["\']'
HASH_KEY_RE = "(#{LITERAL_RE}|#{STRING_RE})"
OBJECT_RE = "(\\s*#{HASH_KEY_RE}(\\s*:\\s*([^,\\n}]+)))+"

EXPORTS_RE = ->
  ///(?:\s|^)(module\.exports|exports)(\s*=\s*\n#{OBJECT_RE}|[=\[.\s].+\n)///gm
SPLIT_MEMBER_RE = -> /\s*=\s*/g
MEMBER_RE = -> ///\[\s*#{STRING_RE}\s*\]|\.#{LITERAL_RE}///
NAME_RE = -> /^[a-zA-Z_$][a-zA-Z0-9_$-.]*$/

PACKAGE_RE = -> ///^(#{LITERAL_RE})(\.#{LITERAL_RE})*$///
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

initValidate = (fn) ->
  fn.validators ||= []
  fn.validate ||= (conf) -> validate conf for validate in fn.validators

validate = (key, regex, expect, fn) =>
  initValidate fn
  fn.validators.push (conf) ->
    unless regex.test conf[key]
      throw new Error _ 'neat.tasks.package.invalid_string', {key, expect}
  fn

malformedConf = (key, type, test, fn) =>
  initValidate fn
  fn.validators.push (conf) ->
    unless test conf
      throw new Error _('neat.tasks.package.invalid_configuration',
                        {key, type})
  fn

preventMissingConf = (key, fn) =>
  initValidate fn
  fn.validators.push (conf) ->
    throw new Error _('neat.tasks.package.missing_configuration',
                      {key}) unless conf[key]?
  fn

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

preventMissingConf 'directory',
createDirectory = (buffer, conf, callback) ->
  newBuffer = {}
  path = "#{conf.dir}/#{conf.directory}"
  ensurePath path, (err) ->
    for p,c of buffer
      newBuffer[p.replace conf.dir, path] = c

    callback?(newBuffer, conf)

validate 'package', PACKAGE_RE(), _('neat.tasks.package.expected_package'),
preventMissingConf 'package',
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

validate 'name', NAME_RE(), _('neat.tasks.package.expected_name'),
preventMissingConf 'name',
join = (buffer, conf, callback) ->
  newBuffer = {}
  newPath = "#{conf.dir}/#{conf.name}.coffee"
  newContent = ''
  newContent += buffer[k] for k of buffer
  newBuffer[newPath] = newContent

  callback?(newBuffer, conf)

uglify = (buffer, conf, callback) ->
  newBuffer = {}
  for path, content of buffer
    ast = parser.parse(content)
    ast = pro.ast_mangle(ast)
    ast = pro.ast_squeeze(ast)
    newBuffer[path.replace /\.js$/g, '.min.js'] = pro.gen_code(ast)

  callback?(newBuffer, conf)

createFile = (buffer, conf, callback) ->
  gen = (path, content) -> (callback) ->
    dir = resolve path, '..'
    ensurePath dir, (err) ->
      writeFile path, content, (err) ->
        callback?()

  parallel (gen k,v for k,v of buffer), ->
    callback?(buffer, conf)

preventMissingConf 'path',
pathChange = (buffer, conf, callback) ->
  newBuffer = {}
  for path, content of buffer
    rel = path.replace "#{Neat.root}/", ''
    path = resolve Neat.root, conf.path, rel.split('/')[1..-1].join('/')
    newBuffer[path] = content

  callback?(newBuffer, conf)

preventMissingConf 'path',
pathReset = (buffer, conf, callback) ->
  path = resolve Neat.root, conf.path
  rm path, (err) ->
    ensurePath path, (err) ->
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
  createDirectory
  compile
  exportsToPackage
  join
  uglify
  createFile
  pathChange
  pathReset
  stripRequires
}
