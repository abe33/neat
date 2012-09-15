fs = require "fs"
{resolve, existsSync:exists} = require 'path'
Neat = require '../neat'

utils = resolve Neat.neatRoot, "lib/utils"
{namespace} = require resolve utils, "exports"
{describe, usages, environment} = require resolve utils, "commands"
{puts, error, info} = require resolve utils, "logs"
{render} = require resolve utils, "templates"
{dirWithIndexSync} = require resolve utils, "files"
cup = require resolve utils, "cup"

usages 'neat generate package.json',
environment 'production',
describe 'Generates the package.json file',
index = (generator, args..., cb) ->

  unless Neat.root?
    throw new Error "Can't run package generator outside of a Neat project."

  ##### 1 - Metadata
  pkg = {}
  fs.readFile resolve(Neat.root, ".neat"), (err, meta) ->
    meta = cup.read meta
    pkg[k] = v for k,v of meta

    ##### 2 - Dependencies (Nemfile)
    fs.readFile 'Nemfile', (err, nemfile) ->
      throw new Error "No #{"Nemfile".red} in the current directory" if err

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
        hasLibIndex = dirWithIndexSync resolve Neat.root, "lib"
        hasSrcIndex = dirWithIndexSync resolve Neat.root, "src"

        pkg.main = './lib/index' if hasLibIndex or hasSrcIndex

        ##### 4 - Binaries
        if exists resolve Neat.root, "bin"
          binaries = fs.readdirSync resolve Neat.root, "bin"
          if binaries?
            pkg.bin = {}
            pkg.bin[bin] = "./bin/#{bin}" for bin in binaries

        ##### 5 - Package.json Generation
        pkgfile = resolve Neat.root, "package.json"
        fs.writeFile pkgfile, JSON.stringify(pkg, null, 2), (err) ->
          throw err if err?
          info "package.json generated".green
          cb?()

module.exports = namespace "package.json", {index}

