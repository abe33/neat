fs = require 'fs'
path = require 'path'
{resolve} = require 'path'
Neat = require '../neat'

{describe, usages, environment, hashArguments} = Neat.require "utils/commands"
{puts, error, info} = Neat.require "utils/logs"
{render} = Neat.require "utils/templates"
{ensurePath} = Neat.require "utils/files"
_ = Neat.i18n.getHelper()

exists = fs.exists or path.exists

usages 'neat generate config:lint {options}',
describe _('neat.commands.generate.config_lint.description'),
exports['config:lint'] = (generator, args..., cb) ->
  throw new Error notOutsideNeat process.argv.join " " unless Neat.root?
  context = if args.empty() then {} else hashArguments args

  dir = resolve Neat.root, 'config/tasks'
  path = "#{dir}/lint.json"
  exists path, (exists) ->
    if exists
      throw new Error _('neat.commands.generate.file_exists', file: path)

    render __filename, context, (err, data) ->
      throw err if err?

      ensurePath dir, (err) ->
        fs.writeFile path, data, (err) ->
          throw new Error _('neat.errors.file_write',
                            file: path, stack: e.stack) if err?
          info _('neat.commands.generate.config_lint.config_generated',
                  config: path).green
          cb?()


