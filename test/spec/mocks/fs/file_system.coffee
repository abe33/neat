{resolve,relative} = require 'path'

class FileSystem
  constructor: (@structure={},@root='/')->
    @root = @removeTrailingSlash @root unless @root is '/'

  read: (path) ->
    path = @normalizePath path
    content = @browseTo path
    if typeof content is 'object' then content.sortedKeys() else content

  exists: (path) ->
    path = @normalizePath path
    @browseTo(path)?

  mkdir: (path) ->
    path = @normalizePath path

    parentPath = resolve path, '..'
    parent = @browseTo parentPath

    throw new Error "No directory at #{parentPath}" unless parent?
    throw new Error "Path already exists" if @exists path

    unless typeof parent is "object"
      throw new Error "#{parentPath} isn't a directory"

    dirname = relative parentPath, path
    parent[dirname] = {}

  write: (path, content) ->
    path = @normalizePath path

    parentPath = resolve path, '..'
    parent = @browseTo parentPath

    throw new Error "No directory at #{parentPath}" unless parent?
    if @exists(path) and typeof @read(path) isnt 'string'
      throw new Error "Can't write into a directory at #{path}"

    filename = relative parentPath, path
    parent[filename] = String(content)

  browseTo: (path) ->
    path = @normalizePath path
    splited = path.split '/'
    result = null
    for key in splited
      result = if key is '' then @structure else result[key]
      return unless result?

    result

  normalizePath: (path) ->
    @removeTrailingSlash(path).replace(@root,'/').squeeze('/')

  removeTrailingSlash: (path) -> path.replace /\/$/, ''

module.exports = {FileSystem}
