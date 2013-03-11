# This file contains some utility to create parameterized generators.

fs = require 'fs'
path = require 'path'
{resolve} = require 'path'
Neat = require '../neat'

{ensurePathSync, noExtension} = Neat.require 'utils/files'
{describe, usages, hashArguments} = Neat.require 'utils/commands'
{render} = Neat.require 'utils/templates'
{error, red, info, green, missing, notOutsideNeat} = Neat.require 'utils/logs'
_ = Neat.i18n.getHelper()

exists = fs.exists or path.exists
existsSync = fs.existsSync or path.existsSync

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
      throw new Error notOutsideNeat process.argv.join ' ' unless Neat.root?

    if typeof name isnt 'string'
      throw new Error _('neat.errors.missing_argument', {name:'name'})

    a = name.split '/'
    name = a.pop()
    dir = resolve Neat.root,"#{dir}/#{a.join '/'}"
    path = resolve dir, "#{name}.#{ext}"

    context = if args.empty() then {} else hashArguments args
    context.merge ctx
    context.merge {name, path, dir, relativePath: a.concat(name).join('/')}
    exists path, (exists) ->
      if exists
        throw new Error _('neat.commands.generate.file_exists',
                               file: path)

      render src, context, (err, data) ->
        throw new Error """#{missing _('neat.templates.template_for',
                                  file: src)}

                        #{err.stack}""" if err?

        ensurePathSync dir
        fs.writeFile path, data, (err) ->
          throw new Error(_('neat.errors.file_write',
                                  file: path, stack: e.stack)) if err

          path = "#{dir}/#{name}.#{ext}"
          info green _('neat.commands.generate.file_generated', {path})
          cb?()


multiEntity = (src, entities, ctx={}, requireNeat=true) ->
  (generator, name, args..., cb) ->
    if requireNeat
      throw new Error notOutsideNeat process.argv.join ' ' unless Neat.root?

    if typeof name isnt 'string'
      throw new Error _('neat.errors.missing_argument', {name:'name'})

    a = name.split '/'
    name = a.pop()
    options = if args.empty() then {} else hashArguments args

    processEntitiesGen = (path,k,v) -> ->
      return if options[k]? and not options[k]
      {dir, ext, partial} = v
      dir = resolve Neat.root,"#{dir}/#{a.join '/'}"
      path = resolve dir, "#{name}#{ext}"
      partial = resolve noExtension(src), partial

      context = ctx.concat()
      context.merge options
      context.merge {name, path, dir, relativePath: a.concat(name).join('/')}

      exists path, (e) ->
        if e
          throw new Error _('neat.commands.generate.file_exists', file: path)

        render partial, context, (err, data) ->
          throw new Error """#{missing _('neat.templates.template_for',
                                    file: src)}

                          #{err.stack}""" if err?

          ensurePathSync dir
          fs.writeFile path, data, (err) ->
            throw new Error(_('neat.errors.file_write',
                            file: path, stack: err.stack)) if err?

            if existsSync path
              path = "#{dir}/#{name}#{ext}"
              info green _('neat.commands.generate.file_generated', {path})
            else
              error red "woah. file '#{path}' coulnd't be created"
            cb?()

    entities.each (k,v) -> processEntitiesGen(path,k,v)()


module.exports = {namedEntity, multiEntity}
