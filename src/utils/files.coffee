# This file contains the various utilities used to work with files
# within a Neat project.

fs = require 'fs'
{resolve, existsSync, exists, basename, relative} = require 'path'
{puts, error, warn, missing} = require './logs'

##### noExtension

# Removes all the extensions from a file name.
noExtension = (o) -> o.replace /([^/.]+)\..+$/, "$1"

##### ensureSync

# Ensures that the `dir` folder exists, and creates it otherwise.
ensureSync = (dir) -> fs.mkdirSync dir unless existsSync dir

##### ensurePathSync

# Ensures that the path exists and creates the missing folders if needed.
ensurePathSync = (path) ->
  dirs = path.split '/'
  dirs.shift()
  p = '/'
  while dirs.length > 0
    d = dirs.shift()
    p = resolve p, d
    fs.mkdirSync p unless existsSync p

##### touchSync

# Creates a file at path unless the file already exists.
touchSync = (path, content='') ->
  fs.writeFileSync path, content unless existsSync path

##### findBaseSync

# Returns an array containing all the paths in `dir` whose base name
# match `base`.
findBaseSync = (dir, base) ->
  return unless existsSync dir

  content = fs.readdirSync dir
  resolve dir, f for f in content when f.match ///^#{base}(\.|$)///

##### isNeatRootSync

# Returns `true` if the passed-in `dir` is a Neat project root directory.
isNeatRootSync = (dir) ->
  existsSync resolve dir, ".neat"

##### neatRootSync

# Finds the first Neat project root directory starting from `path`
# and then moving up along its lineage.
neatRootSync = (path=".") ->
  path = resolve path

  if isNeatRootSync path then path
  else
    parentPath = resolve path, ".."
    neatRootSync parentPath unless parentPath is path

##### dirWithIndexSync

# Returns `true` if the passed-in `dir` is a directory containing an index
# file which extension is `ext`. If no `ext` is provided any file with
# a basename of `index` is returned.
dirWithIndexSync = (dir, ext=null) ->
  return unless existsSync dir

  index = if ext? then "index.#{ext}" else "index"

  findBaseSync(dir, index)?[0]

##### findSiblingFile

# Returns the path to a file related to the provided `path` in a different
# directory structure. If no file can't be found, the function return
# `undefined`
#
# Lets say we have a file in `lib/commands/my_commands`, we want to find
# its sibling template file. We will call `findSiblingFile` like this:
#
#     path = "#{Neat.root}/lib/commands/my_commands/my_file.cmd.js"
#     findSiblingFile path, Neat.paths, 'templates'
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
findSiblingFile = (path, roots, dir, exts..., paths) ->
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
              if p.match ///\.#{ext}$/// then return p else p = undefined
            else
              return p
          # The path is a file, it'll ensure that the path match
          # the extension if provided.
          else if ext isnt "*"
            if p.match ///\.#{ext}$/// then return p else p = undefined
          else
            return p
  # Nothing was found, it returns undefined.
  undefined

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
    findOneSync pattern, ext, paths
  # Otherwise, the search is performed on each path.
  else
    out = []
    for path in paths
      # Results from a search are concatened into the output array.
      founds = findOneSync pattern, ext, path
      out = out.concat founds if founds?
    out

##### findOneSync

# Performs the `find` search routine over a single path.
findOneSync = (pattern, ext, path) ->
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

module.exports = {
  dirWithIndexSync,
  ensureSync,
  ensurePathSync,
  findSync,
  findBaseSync,
  findSiblingFile,
  isNeatRootSync,
  neatRootSync,
  noExtension,
  touchSync,
}
