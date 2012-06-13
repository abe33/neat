{resolve} = require 'path'
{puts, error} = require '../../../utils/logs'

exports.initialize = (config) ->

  config.engines.templates.hamlc =
    render: (tpl, context) ->
      try
        {compile} = require 'haml-coffee'
      catch e
        msg = """#{error 'Haml-coffee module not found, run neat install.'.red}

                 #{e.stack}"""
        return puts msg

      compile(tpl)(context)

