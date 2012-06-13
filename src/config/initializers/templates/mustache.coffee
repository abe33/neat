{resolve} = require 'path'
{puts, error} = require '../../../utils/logs'

exports.initialize = (config) ->

  config.engines.templates.mustache =
    render: (tpl, context) ->
      try
        {to_html} = require 'mustache'
      catch e
        msg = """#{error 'Mustache module not found, run neat install.'.red}

                 #{e.stack}"""
        return puts msg

      to_html tpl, context
