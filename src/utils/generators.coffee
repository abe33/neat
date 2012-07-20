fs = require 'fs'
{resolve} = require 'path'
Neat = require '../neat'

utils = resolve Neat.neatRoot, "lib/utils"
{ensurePathSync} = require resolve utils, "files"
{describe, usages} = require resolve utils, "commands"
{render} = require resolve utils, "templates"
{error, info, missing, notOutsideNeat} = require resolve utils, "logs"

namedEntity = (src, dir, ext, requireNeat=true) ->
  (generator, name, args..., cb) ->
    if requireNeat
      return notOutsideNeat process.argv.join " " unless Neat.root?
    return error "Missing name argument" unless name?

    a = name.split '/'
    name = a.pop()

    render src, {name}, (err, data) ->
      return error """#{missing "Template for #{src}"}

                      #{err.stack}""" if err?

      dir = resolve Neat.root,"src/#{dir}/#{a.join '/'}"
      ensurePathSync dir
      path = resolve dir, "#{name}.#{ext}"
      fs.writeFile path, data, (err) ->
        return error("""#{"Can't write #{path}".red}

                        #{err.stack}""") and cb?() if err
        info "#{dir}/#{name}.#{ext} generated".green
        cb?()

module.exports = {namedEntity}

