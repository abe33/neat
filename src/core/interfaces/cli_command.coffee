{isType} = require '../../utils/matchers'

## CLICommand

# The `CLICommand` interface defines the rules that a function should match
# to be used as a `neat` command.
#
# The rules are simple, the function must have a property named `aliases`
# which contains an array of strings.
CLICommand =
  __definition__: (o) ->
    typeof o is 'function' and o.aliases? and
    Array.isArray(o.aliases) and o.aliases.every isType 'string'

module.exports = CLICommand
