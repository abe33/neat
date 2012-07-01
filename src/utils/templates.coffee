fs = require 'fs'
{resolve, extname} = require 'path'
Neat = require '../neat'

{findSiblingFile} = require "../utils/files"
{puts, error, warn, missing, neatBroken} = require "../utils/logs"

render = (file, context, callback) ->
  a = []
  tplfile = findSiblingFile file, Neat.paths, "templates", "*", a
  [context, callback] = [{}, context] if typeof context is 'function'

  unless tplfile? then callback? new Error """#{missing tplfile}

                                              Explored paths:
                                              #{a.join "\n"}"""

  puts "template found: #{tplfile}"

  ext = extname(tplfile)[1..]

  engines = Neat.env.engines.templates

  render = v.render for k,v of engines when ext is k

  callback? new Error "#{missing "#{ext} template backend"}" unless render?

  puts "engine found for #{ext}"

  fs.readFile tplfile, (err, tpl) ->
    if err then callback? new Error error """Can't access #{tplfile}

                                             #{err.stack}"""

    callback? null, render tpl.toString(), context

renderSync = (file, context) ->
  a = []
  tplfile = findSiblingFile file, Neat.paths, "templates", "*", a

  unless tplfile? then throw new Error """#{missing tplfile}

                                          Explored paths:
                                          #{a.join "\n"}"""

  puts "template found: #{tplfile.green}"

  ext = extname(tplfile)[1..]

  engines = Neat.env.engines.templates

  render = v.render for k,v of engines when ext is k

  unless render?
    throw new Error "#{missing "#{ext} template backend"}"

  puts "engine found for #{ext.cyan}"

  try
    tpl = fs.readFileSync tplfile
  catch e
    e.message = error """Can't access #{tplfile}
                         #{e.message}"""

    throw e

  render tpl.toString(), context

module.exports = {render, renderSync}
