{resolve} = require 'path'
{puts, error} = require '../../../utils/logs'

module.exports = (config) ->

  config.engines.templates.stylus =
    render: (tpl, context) ->
      try
        compile = require 'stylus'
      catch e
        msg = """#{'Stylus module not found, run neat install.'.red}

                 #{e.stack}"""
        return error msg
      output = null
      compile(tpl).render (err, css) -> throw err if err?; output = css
      output

