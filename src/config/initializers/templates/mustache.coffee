{resolve} = require 'path'
{puts, error} = require '../../../utils/logs'

module.exports = (config) ->

  config.engines.templates.mustache =
    render: (tpl, context) ->
      try
        {to_html} = require 'mustache'
      catch e
        msg = """#{'Mustache module not found, run neat install.'.red}

                 #{e.stack}"""
        return error msg

      to_html tpl, context
