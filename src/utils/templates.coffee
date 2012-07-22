# This file contains the utility functions to deal with templates.
# @toc
fs = require 'fs'
{extname} = require 'path'
Neat = require '../neat'

{findSiblingFile, findSiblingFileSync} = require "../utils/files"
{puts, error, missing} = require "../utils/logs"

##### render

# The `render` function will search for a sibling file for `file` in the
# `templates` directory asynchronoulsy and will render that template.
#
#     render __filename, context, (err, content) ->
#       # content contains the results
#
# The engine used to process a given template file is defined using the
# extension of the template file, for instance, with the default engines
# provided in Neat, a `hamlc` file will be processed using the `haml-coffee`
# module, and a `mustache` file will be processed by the `mustache` module.
render = (file, context, callback) ->
  # Arguments are reorganized when a context is not provided.
  [context, callback] = [{}, context] if typeof context is 'function'

  # We first search for a template file.
  findSiblingFile file, Neat.paths, "templates", (e, tplfile, a) ->
    # If either an error is raised or no sibling file can be found,
    # the function callback with an error.
    return callback? e if e?
    unless tplfile?
      return callback? new Error """#{missing "Template for #{file}"}

                                    Explored paths:
                                    #{a.join "\n"}"""

    puts "template found: #{tplfile.yellow}"

    # The extension is extracted from the template file name.
    ext = extname(tplfile)[1..]
    # And the concrete render function is then retrieved.
    {render} = Neat.env.engines.templates[ext]

    # The function callback with an error if no engine can be found
    # for the template file.
    callback? new Error "#{missing "#{ext} template backend"}" unless render?

    puts "engine found for #{ext.cyan}"

    # The template file is then read asynchronoulsy.
    fs.readFile tplfile, (err, tpl) ->
      # The function callback if an error occured while reading the file.
      if err then callback? new Error error """Can't access #{tplfile.red}

                                               #{err.stack}"""

      # The function callback with the rendered content.
      callback? null, render tpl.toString(), context

##### renderSync

# The `renderSync` function will search for a sibling file for `file` in the
# `templates` directory synchronoulsy and will render that template.
#
#     content = renderSync __filename, context
#
# The engine used to process a given template file is defined using the
# extension of the template file, for instance, with the default engines
# provided in Neat, a `hamlc` file will be processed using the `haml-coffee`
# module, and a `mustache` file will be processed by the `mustache` module.
renderSync = (file, context) ->
  # The `paths` array will stores the paths tested for a templates.
  # It will serve as message of the error in the case no file was found.
  paths = []
  # We first search for a template file.
  tplfile = findSiblingFileSync file, Neat.paths, "templates", "*", paths
  # If no sibling file can be found an error is raised.
  unless tplfile?
    return callback? new Error """#{missing "Template for #{file}"}

                                  Explored paths:
                                  #{a.join "\n"}"""

  puts "template found: #{tplfile.yellow}"
  # The extension is extracted from the template file name.
  ext = extname(tplfile)[1..]
  # And the concrete render function is then retrieved.
  {render} = Neat.env.engines.templates[ext]

  # The function raise an error if no engine can be found
  # for the template file.
  unless render?
    throw new Error "#{missing "#{ext} template backend"}"

  puts "engine found for #{ext.cyan}"

  # The template file is then read synchronoulsy.
  try
    tpl = fs.readFileSync tplfile
  catch e
    e.message = error """Can't access #{tplfile.red}
                         #{e.message}"""

    throw e
  # The rendered content is then returned
  render tpl.toString(), context

module.exports = {render, renderSync}
