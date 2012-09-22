# This file contains some utility to create parameterized generators.

fs = require 'fs'
{resolve} = require 'path'
Neat = require '../neat'

utils = resolve Neat.neatRoot, "lib/utils"
{ensurePathSync} = require resolve utils, "files"
{describe, usages, hashArguments} = require resolve utils, "commands"
{render} = require resolve utils, "templates"
{error, info, green, missing, notOutsideNeat} = require resolve utils, "logs"
_ = Neat.i18n.getHelper()

##### namedEntity

# Creates a new generator that create a new file from a template.
# This file can receive optional parameters using the command line
# hash arguments syntax.
#
#  * `src`: The path to the template to use when generating the new file.
#  * `dir`: The path to the root directory in which create the new file.
#  * `ext`: The extension of the new file.
#  * `ctx`: A base context object to use with the template.
#  * `requireNeat`: A boolean that indicates if the generator must be run
#    inside a Neat project.
namedEntity = (src, dir, ext, ctx={}, requireNeat=true) ->
  (generator, name, args..., cb) ->
    if requireNeat
      throw new Error notOutsideNeat process.argv.join " " unless Neat.root?
    throw new Error _('neat.errors.missing_argument', {name}) unless name?

    a = name.split '/'
    name = a.pop()
    dir = resolve Neat.root,"#{dir}/#{a.join '/'}"
    path = resolve dir, "#{name}.#{ext}"

    context = if args.empty() then {} else hashArguments args
    context.merge ctx
    context.merge {name, path, dir}

    render src, context, (err, data) ->
      return error """#{missing "Template for #{src}"}

                      #{err.stack}""" if err?

      ensurePathSync dir
      fs.writeFile path, data, (err) ->
        return error("""#{"Can't write #{path}".red}

                        #{err.stack}""") and cb?() if err

        path = "#{dir}/#{name}.#{ext}"
        info green _('neat.commands.generate.file_generated', {path})
        cb?()

module.exports = {namedEntity}

