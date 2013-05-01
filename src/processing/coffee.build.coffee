# @toc

Q = require 'q'
{compile:coffee} = require 'coffee-script'
{check, checkBuffer} = require './utils'

LITERAL_RE = '[a-zA-Z_$][a-zA-Z0-9_$]*'
STRING_RE = '["\'][^"\']+["\']'
HASH_KEY_RE = "(#{LITERAL_RE}|#{STRING_RE})"
OBJECT_RE = "(\\s*#{HASH_KEY_RE}(\\s*:\\s*([^,\\n}]+)))+"

EXPORTS_RE = ->
  ///
    (?:\s|^)                  # Indent or line start
    (module\.exports|exports) # The exports affectation
    (
      \s*=\s*\n#{OBJECT_RE}   # Either an object literal
      |
      [=\[.\s].+\n            # Or an expression
    )
  ///gm
SPLIT_MEMBER_RE = -> /\s*=\s*/g
MEMBER_RE = -> ///\[\s*#{STRING_RE}\s*\]|\.#{LITERAL_RE}///
NAME_RE = -> /^[a-zA-Z_$][a-zA-Z0-9_$-.]*$/

PACKAGE_RE = -> ///^(#{LITERAL_RE})(\.#{LITERAL_RE})*$///
HASH_VALUE_RE = '(\\s*:\\s*([^,}]+))*'
HASH_RE = -> ///\{(#{HASH_KEY_RE}#{HASH_VALUE_RE},*\s*)+\}///
REQUIRE_RE = -> ///require\s*(\(\s*)*#{STRING_RE}///gm
CLASS_RE = -> ///^([^#]*)class\s*(#{LITERAL_RE})///
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

##### analyze
analyze = (path, content) ->
  out = content.concat()
  i2 = 0
  curClass = null
  for line,i in content
    comment = null
    if CLASS_RE().test line
      [m,s,curClass] = CLASS_RE().exec line
      comment = "#{s}`/* #{path}<#{curClass}> line:#{i+1} */`"

    if CLASS_MEMBER_RE().test line
      [m,s,p] = CLASS_MEMBER_RE().exec line
      comment = "#{s}`/* #{path}<#{curClass}::#{p}> line:#{i+1} */`"

    if STATIC_MEMBER_RE().test line
      [m,s,p] = STATIC_MEMBER_RE().exec line
      comment = "#{s}`/* #{path}<#{curClass}.#{p}> line:#{i+1} */`"

    if comment?
      out.splice i2, 0, comment
      i2++

    i2++
  out

##### annotate
annotate = (buffer) ->
  checkBuffer buffer

  Q.fcall ->
    newBuffer = {}
    for path, content of buffer
      content = content.split('\n')
      content = analyze path, content
      newBuffer[path] = "`/* #{path} */`\n#{content.join('\n')}"

    newBuffer

##### exportsToPackage
exportsToPackage = (pkg) ->
  check pkg, 'Missing package argument'

  return (buffer) ->
    checkBuffer buffer

    Q.fcall ->
      newBuffer = {}
      header = ->
        header = ''
        packages = pkg.split '.'
        _pkg = "@#{packages.shift()}"
        header += "#{_pkg} ||= {}\n"
        for p in packages
          _pkg += ".#{p}"
          header += "#{_pkg} ||= {}\n"

        "#{header}\n"

      convertExports = (content) ->
        packageFor = (k,v) -> "@#{pkg}.#{k} = #{v || k}"

        exp = []
        content = content.replace EXPORTS_RE(), (m,e,p) =>
          [member, value] = p.split SPLIT_MEMBER_RE()

          if MEMBER_RE().test member
            "@#{pkg}#{p}"
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
              exp.push "@#{pkg}.#{value} = #{value}"
            ''
        "#{content}\n#{exp.join '\n'}"

      for path, content of buffer
        newBuffer[path] = "#{header()}#{convertExports content}"

      newBuffer

##### compile
compile = (options={}) -> (buffer) ->
  checkBuffer buffer

  Q.fcall ->
    newBuffer = {}
    try
      for path, content of buffer
        opts = options.concat()
        newBuffer[path.replace '.coffee', '.js'] = coffee content, opts
    catch e
      throw new Error "In file '#{path}': #{e.message}"

    newBuffer

##### stripRequires
stripRequires = (buffer) ->
  checkBuffer buffer

  Q.fcall ->
    newBuffer = {}
    for path, content of buffer
      newBuffer[path] = content.split('\n')
                            .reject((s) -> REQUIRE_RE().test s)
                            .join('\n')
    newBuffer


module.exports = {compile, annotate, exportsToPackage, stripRequires}
