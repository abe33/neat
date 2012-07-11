{isType} = require '../../utils/matchers'

CLICommand =
  __definition__: (o) ->
    typeof o is 'function' and o.aliases? and
    Array.isArray(o.aliases) and o.aliases.every isType 'string'

module.exports = CLICommand
