fs = require 'fs'
{resolve} = require 'path'
Neat = require '../neat'

{describe, usages, environment, hashArguments} = Neat.require "utils/commands"
{puts, error, info} = Neat.require "utils/logs"
{render} = Neat.require "utils/templates"
{ensurePath} = Neat.require "utils/files"
_ = Neat.i18n.getHelper()

usages 'neat generate config:lint {options}',
describe _('neat.commands.generate.config_lint.description'),
exports['config:lint'] = (generator, args..., cb) ->
  throw new Error notOutsideNeat process.argv.join " " unless Neat.root?
  context = if args.empty() then {} else hashArguments args

  render __filename, context, (err, data) ->
    throw err if err?

    path = resolve Neat.root, 'config/tasks'

    ensurePath path, (err) ->
      path = "#{path}/lint.json"

      fs.writeFile path, data, (err) ->
        return error("""#{"Can't write #{path}".red}

                        #{err.stack}""") and cb?() if err
        info _('neat.commands.generate.config_lint.config_generated',
                config: path).green
        cb?()


