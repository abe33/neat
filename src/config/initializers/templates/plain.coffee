exports.initialize = (config) ->

  config.engines.templates.plain = render: (tpl, context) -> tpl
