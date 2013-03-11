# This file contains some utilities to deal with exports and requires.
# @toc

{resolve, basename} = require 'path'

{puts, error, warn, missing} = require './logs'
{findSync} = require "../utils/files"

##### namespace

# Decorates an object properties with the given `namespace`.
# Given a property `parse` on the passed-in object and the namespace `json`,
# the resulting object will contains a property named `json:parse`.
#
# If the object contains a property named `index`, then its content will
# be available in the resulting object with the namespace alone.
#
#     namespace 'foo',
#       index: -> # ...
#       bar: -> # ...
#
#     # { foo: [Function], 'foo:bar': [Function] }
namespace = (namespace, exports) ->
  packaged = {}
  packaged[namespace] = exports["index"] if exports["index"]?
  packaged["#{namespace}:#{k}"] = v for k,v of exports when k isnt "index"
  packaged

##### combine

# Combines in a single object all the exports of files that match
# the passed-in `filePattern` that can be found in `paths` directories.
# The search is performed recursively in the subdirectories of each path.
#
# This function is used to aggregate all the commands and generators
# in a project and initialize the Neat command line tool with them.
#
# Below is a real world example from the generators index file.
#
#     Neat = require '../neat'
#     {combine} = require "../utils/exports"
#
#     paths = Neat.paths.map (p) -> "#{p}/lib/generators"
#     module.exports = combine /\.gen$/, paths
combine = (filePattern, paths) ->
  [filePattern, paths] = [paths, filePattern] if Array.isArray filePattern

  files = findSync filePattern, 'js', paths

  packaged = {}
  for file in files
    # The `require` calls are protected against errors to prevent
    # the Neat command line tool to be broken by a failing commands.
    try
      required = require file
      packaged[k] = v for k,v of required
    catch e
      s = error """#{"Broken file #{file}".red}

                   #{e.stack}"""
      error s.red

  packaged

module.exports = {namespace, combine}
