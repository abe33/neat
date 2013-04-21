# This file contains the various utilities used to work with files
# within a Neat project.
# @toc

fs = require 'fs'
path = require 'path'
{resolve, basename, relative, extname} = require 'path'
{puts, error, warn, missing} = require './logs'
{parallel} = require '../async'

existsSync = fs.existsSync or path.existsSync
exists = fs.exists or path.exists

##### dirWithIndex

# Returns the path to the `index` present in the `dir` directory
# if this directory contains an index file which extension is `ext`.
# If no `ext` is provided any file with a basename of `index` is returned.
#
#     dirWithIndex '/path/to/dir', (index) ->
#       if index?
#         # do something with the index
#
#     dirWithIndex '/path/to/dir', 'js', (index) ->
#       if index?
#         # do something with index.js
dirWithIndex = (dir, ext=null, callback) ->
  [ext, callback] = [callback, ext] if typeof ext is 'function'
  exists dir, (b) ->
    return callback?() unless b

    index = if ext? then "index.#{ext}" else "index"

    findBase dir, index, (res) ->
      callback res?[0]

##### dirWithIndexSync

# Returns the path to the `index` present in the `dir` directory
# if this directory contains an index file which extension is `ext`.
# If no `ext` is provided any file with a basename of `index` is returned.
#
#     index = dirWithIndexSync '/path/to/dir'
#     if index?
#       # do something with the index
#
#     index = dirWithIndexSync '/path/to/dir', 'js'
#     if index?
#       # do something with index.js
dirWithIndexSync = (dir, ext=null) ->
  return unless existsSync dir

  index = if ext? then "index.#{ext}" else "index"

  findBaseSync(dir, index)?[0]

##### ensure

# Ensures that the `dir` folder exists, and creates it otherwise.
#
#     ensure '/path/to/dir', (err, created) ->
#       # handle errors
#
# The `created` argument of the callback function is a boolean
# value that indicates if the directory was created or not.
ensure = (dir, callback) ->
  exists dir, (b) ->
    if b then callback? null, false
    else fs.mkdir dir, (err) ->
      if err? then callback? err, false
      else callback? null, true

##### ensureSync

# Ensures that the `dir` folder exists, and creates it otherwise.
#
#     ensureSync '/path/to/dir'
#
# Note that the function will fail with an error in this
# context if `/path/to` don't exist.
ensureSync = (dir) ->
  (fs.mkdirSync dir; return true) unless existsSync dir; false

##### ensurePath

# Ensures that the path exists and creates the missing folders if needed.
#
#     ensurePath '/path/to/dir', (err, created) ->
#       # handle error
#
# In that context, if the `path` and `to` folders don't exist
# they will be created and then the `dir` one.
#
# The `created` argument of the callback function is a boolean
# value that indicates if the directory was created or not.
ensurePath = (path, callback) ->
  stack = []
  generator = (d) -> (callback) -> ensure d, callback
  next = (err, created) ->
    callback? err, false if err?
    if stack.length > 0 then stack.shift()? next else callback? null, created

  dirs = path.split('/')[1..-1]
  p = ''

  stack.push generator p = "#{p}/#{d}" for d in dirs

  next()

##### ensurePathSync

# Ensures that the path exists and creates the missing folders if needed.
#
#     ensurePathSync '/path/to/dir'
#
# In that context, if the `path` and `to` folders don't exist
# they will be created and then the `dir` one.
ensurePathSync = (path) ->
  dirs = path.split '/'
  dirs.shift()
  p = '/'
  while dirs.length > 0
    d = dirs.shift()
    p = resolve p, d
    fs.mkdirSync p unless existsSync p


##### find

# Returns an array containing the paths to files in `paths` that match
# both the provided `pattern` and `ext`.
#
# For instance, the following call will returns the path to all the commands
# in the `lib/commands` directories of a Neat project.
#
#     paths = Neat.paths.map (p)-> "#{p}/lib/commands"
#     find /\.cmd$/, 'js', paths, (err, commands) ->
#       # do something with commands
#
# The `pattern` argument is optional and match against the `basename`
# of the file.
find = (pattern, ext, paths, callback) ->
  # Arguments are reorganized if no pattern is provided.
  [pattern, ext, paths, callback] = [
    null,
    pattern,
    ext
    paths
  ] if typeof pattern is "string"

  # If `paths` is a string, the search is performed on this sole path.
  if typeof paths is "string"
    findOnce pattern, ext, paths, callback
  # Otherwise, the search is performed on each path.
  else
    output = []
    lookup = (pattern, ext, paths) -> (cb) ->
      findOnce pattern, ext, paths, (err, files) ->
        output.push file for file in files if files?
        cb?()

    if paths.empty()
      callback? null, output
    else
      parallel (lookup(pattern, ext, p) for p in paths), ->
        callback? null, output

##### findOnce

# Performs the `find` search routine over a single path.
findOnce = (pattern, ext, path, callback, output) ->

  exists path, (b) ->
    callback? new Error '' unless b?
    # Stores the results of the search.
    out = []
    # Matchs the file extension.
    extRe = ///\.#{ext}$///

    lookup = (path, output) -> (cb) ->
      p = basename path
      fs.lstat path, (err, stats) ->
        if stats.isDirectory()
          # The search continue in the directory.
          find pattern, ext, path, (err, files) ->
            return callback? err if err?

            output.push file for file in files if files?

            # When a `pattern` is provided and the directory name match
            # against it, the function will then look for the presence
            # of an index file.
            index = resolve path, "index.#{ext}"
            exists index, (b) ->
              if pattern? and p.match(pattern) and b
                output.push index

              cb?()
        # The path is a file that match the specified file extension.
        else if p.match extRe
          # If a `pattern` is provided and the file match against it,
          # the path is set as a found.
          if pattern?
            if p.replace(extRe,'').match pattern
              found = path
          # Otherwise the path is a found by default.
          else
            found = path
          # The paths found in this directory are added to the output array.
          output.push(found) if found?

          cb?()
        else cb?()

    # Reads the current directory.
    fs.readdir path, (err, content)->
      throw err if err?
      output = []

      if content.empty()
        callback? null, output
      else
        parallel (lookup(resolve(path, p), output) for p in content), ->
          callback? null, output

##### findSync

# Returns an array containing the paths to files in `paths` that match
# both the provided `pattern` and `ext`.
#
# For instance, the following call will returns the path to all the commands
# in the `lib/commands` directories of a Neat project.
#
#     paths = Neat.paths.map (p)-> "#{p}/lib/commands"
#     commands = find /\.cmd$/, 'js', paths
#
# The `pattern` argument is optional and match against the `basename`
# of the file.
findSync = (pattern, ext, paths) ->
  # Arguments are reorganized if no pattern is provided.
  [pattern, ext, paths] = [null, pattern, ext] if typeof pattern is "string"

  # If `paths` is a string, the search is performed on this sole path.
  if typeof paths is "string"
    findSyncOnce pattern, ext, paths
  # Otherwise, the search is performed on each path.
  else
    out = []
    for path in paths
      # Results from a search are concatened into the output array.
      founds = findSyncOnce pattern, ext, path
      out = out.concat founds if founds?
    out

##### findSyncOnce

# Performs the `findSync` search routine over a single path.
findSyncOnce = (pattern, ext, path) ->
  return unless existsSync path

  # Stores the results of the search.
  out = []
  # Matchs the file extension.
  extRe = ///\.#{ext}$///

  # Reads the current directory.
  content = fs.readdirSync path
  for p in content
    # `found` will stores the results of the searches.
    found = null

    # Constructs the path to test.
    _path = resolve path, p
    # And retreives information for this path.
    stats = fs.lstatSync _path
    # The path is a directory.
    if stats.isDirectory()
      # The search continue in the directory.
      found = findSync pattern, ext, _path

      # When a `pattern` is provided and the directory name match against it,
      # the function will then look for the presence of an index file.
      index = resolve _path, "index.#{ext}"
      if pattern? and p.match(pattern) and existsSync index
        found ?= []
        found.push index
    # The path is a file that match the specified file extension.
    else if p.match extRe
      # If a `pattern` is provided and the file match against it,
      # the path is set as a found.
      if pattern?
        if p.replace(extRe,'').match pattern
          found = _path
      # Otherwise the path is a found by default.
      else
        found = _path
    # The paths found in this directory are added to the output array.
    out = out.concat(found) if found?

  # If the output array is not empty the array is returned, otherwise
  # the function returns `null`.
  if out.length > 0 then out else null

##### findBase

# Returns an array containing all the paths in `dir` whose name
# match `base`.
#
#     findBase '/path/to/dir', 'file', (files) ->
#       # files = [
#       #   /path/to/dir/file.coffee
#       #   /path/to/dir/file.js
#       #   /path/to/dir/file.spec.coffee
#       # ]
findBase = (dir, base, callback) ->
  exists dir, (b) ->
    return callback?() unless b

    fs.readdir dir, (err, content) ->
      return callback?() if err?

      res = (resolve dir, f for f in content when f.match ///^#{base}(\.|$)///)
      callback? res

##### findBaseSync

# Returns an array containing all the paths in `dir` whose name
# match `base`.
#
#     files = findBaseSync '/path/to/dir', 'file'
#     # files = [
#     #   /path/to/dir/file.coffee
#     #   /path/to/dir/file.js
#     #   /path/to/dir/file.spec.coffee
#     # ]
findBaseSync = (dir, base) ->
  return unless existsSync dir

  content = fs.readdirSync dir
  resolve dir, f for f in content when f.match ///^#{base}(\.|$)///

##### findSiblingFile

# Look for a file related to the provided `path` in a different
# directory structure.
#
# Lets say we have a file in `lib/commands/my_commands`, we want to find
# its sibling template file. We will call `findSiblingFile` like this:
#
#     path = "#{Neat.root}/lib/commands/my_commands/my_file.cmd.js"
#     findSiblingFile path, Neat.paths, 'templates', (err, file) ->
#       # file is either undefined
#       # or a string containing the found file path
#
# This basic exemple will return any file in `templates/commands/my_commands`
# with a base name that match the one of the original file. For instance, in
# our case, a file named `my_file.html.hamlc` could be returned if it exists
# in the corresponding folder.
# If a directory has the same name as the base name of the source file, and
# it contains an `index` file that match the criteria, the path to the index
# is returned.
#
# The `exts` splats allow to define a list of allowed extensions for the
# searched files. You can use `'*'` to allow any extension.
findSiblingFile = (path, roots, dir, exts..., callback) ->
  paths = []

  # The specified `path` must be in a Neat project.
  neatRoot path, (pathRoot) ->
    return callback? new Error(), undefined, [] unless pathRoot?

    # Prepares the path structure that will be used in the search.
    # Note that, unlike the `basename` function, all the extensions
    # are removed from the path. It allow to use additional extensions
    # in file names and at the same time to don't have to duplicate this
    # additional extensions in the searched files.
    start = noExtension path
    base = basename start
    dif = relative pathRoot, resolve start, ".."
    newPath = dif.replace /^[^\/]+/, dir
    exts = '*' if not exts? or
                  exts.empty() or
                  (exts.length is 1 and exts[0] is '*')

    # Will hold the tested path.
    p = undefined

    # The roots paths are reverted to prioritize the user and plugins
    # directories over the Neat directory, allowing a user or a plugin
    # to *override* that file.
    roots = roots.concat()
    roots.reverse()
    matches = {}
    found = []
    matchExtensions = (p) -> extname(p).substr(1) in exts or exts is "*"
    # The `lookup` function generates a command that perform the lookup
    # for the given `root`.
    lookup = (root) -> (cb) ->
      # Constructs a path to the directory that should contains
      # the searched file.
      basepath = resolve root, newPath

      paths.push basepath

      # Retrieves all the files or directories that match the base name.
      findBase basepath, base, (ps) ->
        # If there's matches.
        if ps? and not ps.empty()
          ps.sort()

          # The `entryMatch` function generates a command that perform
          # the lookup for a path whose base match the original file.
          entryMatch = (p) -> (cb) ->
            fs.lstat p, (err, stats) ->
              return callback? err, null, path if err?
              paths.push p
              # The path is a directory.
              if stats.isDirectory()
                # Stores in `paths` the current searched path.
                paths.push resolve p, 'index.*'

                # Looks for an index file in the directory.
                dirWithIndex p, (ip) ->
                  if ip? and matchExtensions ip
                    matches[roots.indexOf root] ||= []
                    matches[roots.indexOf root].push ip
                  cb?()
              else
                # The path is a file, it'll ensure that the path match
                # the extension if provided.
                if matchExtensions p
                  matches[roots.indexOf root] ||= []
                  matches[roots.indexOf root].push p
                cb?()
          # Runs a verification on each path returned by `findBase`.
          parallel (entryMatch(p) for p in ps), ->
            found.push matches[i] for r,i in roots
            found = found.flatten().compact()
            cb?()
        # Nothing was returned by `findBase`, the lookup callback.
        else cb?()

    # In the case `roots` is empty, the function callback.
    if roots.empty()
      callback? null, null, paths
    # Otherwise a lookup is perform for each root.
    else
      parallel (lookup(root) for root in roots), ->
        callback? null, found.sort()[0], paths

##### findSiblingFileSync

# Returns the path to a file related to the provided `path` in a different
# directory structure. If no file can't be found, the function return
# `undefined`
#
# Lets say we have a file in `lib/commands/my_commands`, we want to find
# its sibling template file. We will call `findSiblingFileSync` like this:
#
#     path = "#{Neat.root}/lib/commands/my_commands/my_file.cmd.js"
#     findSiblingFileSync path, Neat.paths, 'templates'
#
# This basic exemple will return any file in `templates/commands/my_commands`
# with a base name that match the one of the original file. For instance, in
# our case, a file named `my_file.html.hamlc` could be returned if it exists
# in the corresponding folder.
# If a directory has the same name as the base name of the source file, and
# it contains an `index` file that match the criteria, the path to the index
# is returned.
#
# The `exts` splats allow to define a list of allowed extensions for the
# searched files. You can use `'*'` to allow any extension.
#
# The `paths` argument is optional, pass an array and the function will
# collect in this array all the paths that was tried during the call.
findSiblingFileSync = (path, roots, dir, exts..., paths) ->
  # The specified `path` must be in a Neat project.
  pathRoot = neatRootSync path

  return unless pathRoot?

  # If `path` is a string, no array was passed to collect the paths
  # and then we add the string as an extension to match.
  [exts, paths] = [exts.concat(paths), null] if typeof paths is "string"

  # Prepares the path structure that will be used in the search.
  # Note that, unlike the `basename` function, all the extensions
  # are removed from the path. It allow to use additional extensions
  # in file names and at the same time to don't have to duplicate this
  # additional extensions in the searched files.
  start = noExtension path
  base = basename start
  dif = relative pathRoot, resolve start, ".."
  newPath = dif.replace /^[^\/]+/, dir

  # Ensure that `exts` is an array containing at least one string.
  exts = "*" unless exts?
  exts = [exts] unless typeof exts is "object"

  # Will hold the tested path.
  p = undefined

  # The roots paths are reverted to prioritize the user and plugins
  # directories over the Neat directory, allowing a user or a plugin
  # to *override* that file.
  roots = roots.concat()
  roots.reverse()

  for root in roots
    # Constructs a path to the directory that should contains
    # the searched file.
    basepath = resolve root, newPath

    for ext in exts
      # Stores in `paths` the current searched path with the extension
      # if provided.
      paths?.push resolve basepath,
                          if ext is "*" then base else "#{base}.#{ext}"

      # Retrieves all the files or directories that match the base name.
      ps = findBaseSync basepath, base

      # If there's matches.
      if ps?
        ps.sort()

        for p in ps
          # We don't have to protect the call to `lstatSync` since the
          # `findPathWithBase` returns only existing paths.
          stats = fs.lstatSync p

          # The path is a directory.
          if stats.isDirectory()
            # Stores in `paths` the current searched path with the extension
            # if provided.
            paths?.push resolve p, if ext is "*"
              "index"
            else
              "index.#{ext}"

            # Looks for an index file in the directory.
            p = dirWithIndexSync p

            # Ensures that the index match the extension if provided.
            if ext isnt "*"
              if p?.match ///\.#{ext}$/// then return p else p = undefined
            else
              return p
          # The path is a file, it'll ensure that the path match
          # the extension if provided.
          else if ext isnt "*"
            if p?.match ///\.#{ext}$/// then return p else p = undefined
          else
            return p
  # Nothing was found, it returns undefined.
  undefined

##### isNeatRoot

# Returns `true` if the passed-in `dir` is a Neat project root directory.
#
#     isNeatRoot '/path/to/dir', (found) ->
#       if found
#         # '/path/to/project' is a neat project root
isNeatRoot = (dir, callback) ->
  exists resolve(dir, ".neat"), callback

##### isNeatRootSync

# Returns `true` if the passed-in `dir` is a Neat project root directory.
#
#     if isNeatRootSync '/path/to/dir'
#       # '/path/to/project' is a neat project root
isNeatRootSync = (dir) ->
  existsSync resolve dir, ".neat"

##### neatRoot

# Finds the first Neat project root directory starting from `path`
# and then moving up along its lineage.
#
#     neatRoot __filename, (root) ->
#       if root?
#         # the current file is part of a neat project
#         # root = '/path/to/project'
neatRoot = (path=".", callback) ->
  path = resolve path

  isNeatRoot path, (bool) ->
    if bool then return callback? path
    else
      parentPath = resolve path, ".."

      if parentPath is path then return callback?()
      neatRoot parentPath, callback

##### neatRootSync

# Finds the first Neat project root directory starting from `path`
# and then moving up along its lineage.
#
#     root = neatRootSync __filename
#     if root?
#       # the current file is part of a neat project
#       # root = '/path/to/project'
neatRootSync = (path=".") ->
  path = resolve path

  if isNeatRootSync path then path
  else
    parentPath = resolve path, ".."
    neatRootSync parentPath unless parentPath is path

##### noExtension

# Removes all the extensions from a file name.
#
#     noExtension 'foo.bar.baz' # 'foo'
noExtension = (o) ->
  p = o.split '/'
  last = p.pop()
  last = last.replace /([^/.]+)\..+$/, "$1"
  p.concat(last).join('/')

##### readFiles

# Reads an array of path and return a hash with the path
# of the file as key and the content of the file as value.
#
#     readFiles ['foo.txt', 'bar.txt'], (err, docs) ->
#       # docs = {'foo.txt': '...', 'bar.txt': '...'}
readFiles = (files, callback) ->
  res = {}
  error = null
  readIteration = (path) -> (cb) ->
    fs.readFile path, (err, content) ->
      return (error = err; cb()) if err?

      res[path] = String(content)
      cb()

  parallel (readIteration p for p in files), ->
    callback? error, res

##### readFilesSync

# Reads an array of path and return a hash with the path
# of the file as key and the content of the file as value.
#
#     docs = readFiles ['foo.txt', 'bar.txt']
#      # docs = {'foo.txt': '...', 'bar.txt': '...'}
readFilesSync = (files) ->
  res = {}
  res[path] = fs.readFileSync path for path in files
  res

##### rm

rm = (path, callback) ->
  rmIteration = (path) -> (callback) -> rm path, callback

  exists path, (exist) ->
    if exist
      fs.lstat path, (err, stats) ->
        return callback? err if err?
        if stats.isDirectory()
          fs.readdir path, (err, paths) ->
            return callback? err if err?
            parallel (rmIteration "#{path}/#{p}" for p in paths), ->
              fs.rmdir path, (err) -> callback? err
        else
          fs.unlink path, (err) -> callback? err
    else
      callback?()

##### rmSync

rmSync = (path) ->
  if existsSync path
    stats = fs.lstatSync path
    if stats.isDirectory()
      paths = fs.readdirSync path
      rmSync "#{path}/#{p}" for p in paths if paths?
      fs.rmdirSync path
    else
      fs.unlinkSync path

##### touch

# Creates a file at path unless the file already exists.
#
#     touch '/path/to/file.ext', (err, created) ->
#       # handle errors
#
#     touch '/path/to/file.ext', 'file content', (err, created) ->
#       # handle errors
touch = (path, content='', callback) ->
  [content, callback] = [callback, content] if typeof content is 'function'
  exists path, (b) ->
    if b then callback? null, false
    else fs.writeFile path, content, (err) ->
      if err? then callback? err, false
      else callback? null, true

##### touchSync

# Creates a file at path unless the file already exists.
# A boolean value is returned and indicate if the file was created.
#
#     touchSync '/path/to/file.ext'
#
#     touchSync '/path/to/file.ext', 'file content'
#
# Note that the function will fail with an error in this
# context if `/path/to` don't exist.
touchSync = (path, content='') ->
  (fs.writeFileSync path, content; return true) unless existsSync path
  false

module.exports = {
  dirWithIndex,
  dirWithIndexSync,
  ensure,
  ensureSync,
  ensurePath,
  ensurePathSync,
  find,
  findSync,
  findBase,
  findBaseSync,
  findSiblingFile,
  findSiblingFileSync,
  isNeatRoot,
  isNeatRootSync,
  neatRoot,
  neatRootSync,
  noExtension,
  readFiles,
  readFilesSync,
  rm,
  rmSync,
  touch,
  touchSync,
}
