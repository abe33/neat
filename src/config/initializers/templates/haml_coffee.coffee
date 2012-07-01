{resolve} = require 'path'
{puts, error} = require '../../../utils/logs'

module.exports = (config) ->

  config.engines.templates.hamlc =
    render: (tpl, context) ->
      try
        {compile} = require 'haml-coffee'
      catch e
        msg = """#{'Haml-coffee module not found, run neat install.'.red}

                 #{e.stack}"""
        return error msg

      compile(tpl)(context)

