Neat = require '../../../lib/neat'
Packager = require '../../../lib/tasks/package/packager'
op = require '../../../lib/tasks/package/operators'
{ensurePathSync, rmSync} = Neat.require 'utils/files'

Neat.config =
  tasks:
    package:
      conf: "#{Neat.root}/src/config/packages"
      dir: "#{Neat.root}/.tests/packages"
      tmp: "#{Neat.root}/.tmp"
      operatorsMap:
        'annotate:class': op.annotateClass
        'annotate:file': op.annotateFile
        'join': op.join
        'compile': op.compile
        'create:directory': op.createDirectory
        'strip:requires': op.stripRequires
        'exports:package': op.exportsToPackage
        'create:file': op.saveToFile

global.packagerWithFiles = (files, bare=false, block) ->
  [bare, block] = [null, bare] if typeof bare is 'function'

  describe "with [#{files}] as target", ->
    beforeEach ->
      @packager = new Packager
        name: 'fixtures'
        package: 'neat.fixtures'
        directory: 'directory'
        includes: files
        bare: bare
        operators: [
          'strip:requires'
          'annotate:class'
          'annotate:file'
          'join'
          'exports:package'
          'create:directory'
          'create:file'
        ]

      ensurePathSync Neat.config.tasks.package.dir

      ended = false
      runs ->
        @packager.process =>
          @result = @packager.result
          ended = true

      waitsFor progress(-> ended), 'Timed out', 1000

    afterEach ->
      rmSync Neat.config.tasks.package.dir

    block?.call(this)

global.packagerWithFile = (file, bare=true, block) ->
  packagerWithFiles [file], bare, block
