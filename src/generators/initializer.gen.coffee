fs = require 'fs'
{resolve} = require 'path'
Neat = require '../neat'

utils = resolve Neat.neatRoot, "lib/utils"
{ensurePathSync} = require resolve utils, "files"
{namespace} = require resolve utils, "exports"
{describe, usages} = require resolve utils, "commands"
{render} = require resolve utils, "templates"
{puts, error, info, missing, notOutsideNeat} = require resolve utils, "logs"

usages 'neat generate initializer [name]',
describe 'Generates a [name] initializer in the config/initializers directory',
initializer = (generator, name, args..., cb) ->
  return notOutsideNeat "neat generate initializer" unless Neat.root?
  return error "Missing name argument" unless name?

  a = name.split '/'
  name = a.pop()

  render __filename, {name}, (err, data) ->
    return """#{missing "Template for #{__filename}"}

              #{err.stack}""" if err?

    dir = resolve Neat.root,"src/config/initializers/#{a.join '/'}"
    ensurePathSync dir
    path = resolve dir, "#{name}.coffee"
    fs.writeFile path, data, (err) ->
      return error("""#{"Can't write #{path}".red}

                           #{err.stack}""") and cb?() if err
      info "#{dir}/#{name}.coffee generated".green
      cb?()

module.exports = {initializer}
