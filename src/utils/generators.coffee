fs = require 'fs'
{resolve} = require 'path'
Neat = require '../neat'

utils = resolve Neat.neatRoot, "lib/utils"
{ensurePathSync} = require resolve utils, "files"
{describe, usages, hashArguments} = require resolve utils, "commands"
{render} = require resolve utils, "templates"
{error, info, missing, notOutsideNeat} = require resolve utils, "logs"

namedEntity = (src, dir, ext, ctx={}, requireNeat=true) ->
  (generator, name, args..., cb) ->
    if requireNeat
      return notOutsideNeat process.argv.join " " unless Neat.root?
    return error "Missing name argument" unless name?

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
        info "#{dir}/#{name}.#{ext} generated".green
        cb?()

module.exports = {namedEntity}

