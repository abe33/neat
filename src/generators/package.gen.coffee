fs = require 'fs'
path = require 'path'
{resolve} = require 'path'
Neat = require '../neat'

{namespace} = Neat.require "utils/exports"
{describe, usages, environment} = Neat.require "utils/commands"
{puts, error, info, notOutsideNeat} = Neat.require "utils/logs"
{render} = Neat.require "utils/templates"
{dirWithIndexSync} = Neat.require "utils/files"
cup = Neat.require "utils/cup"
_ = Neat.i18n.getHelper()

existsSync = fs.existsSync or path.existsSync

usages 'neat generate package.json',
environment 'production',
describe _('neat.commands.generate.package.description'),
index = (generator, args..., cb) ->

  unless Neat.root?
    throw new Error notOutsideNeat 'package generator'

  ##### 1 - Metadata
  pkg = {}
  fs.readFile resolve(Neat.root, ".neat"), (err, meta) ->
    meta = cup.read meta
    pkg[k] = v for k,v of meta

    ##### 2 - Dependencies (Nemfile)
    fs.readFile 'Nemfile', (err, nemfile) ->
      throw new Error _('neat.error.no_nemfile') if err

      puts "Nemfile found"

      path = resolve __dirname, "package/dependencies"
      context = npm: nemfile.toString().replace /^(.|$)/gm,"  $1"

      render path, context, (err, source) ->
        throw err if err?

        dependencies = cup.read source
        return unless dependencies?

        pkg.dependencies = {}
        pkg.devDependencies = {}

        for g,a of dependencies
          if g in ["default", "production"]
            pkg.dependencies[p] = v or "*" for [p,v] in a
          else
            pkg.devDependencies[p] = v or "*" for [p,v] in a

        ##### 3 - Main File
        unless pkg.main?
          hasLibIndex = dirWithIndexSync resolve Neat.root, "lib"
          hasSrcIndex = dirWithIndexSync resolve Neat.root, "src"

          pkg.main = './lib/index' if hasLibIndex or hasSrcIndex

        ##### 4 - Binaries
        if existsSync resolve Neat.root, "bin"
          binaries = fs.readdirSync resolve Neat.root, "bin"
          if binaries?
            pkg.bin = {}
            pkg.bin[bin] = "./bin/#{bin}" for bin in binaries

        ##### 5 - Package.json Generation
        pkgfile = resolve Neat.root, "package.json"
        fs.writeFile pkgfile, JSON.stringify(pkg, null, 2), (err) ->
          throw err if err?
          info _('neat.commands.generate.package.package_generated').green
          cb?()

module.exports = namespace "package.json", {index}
