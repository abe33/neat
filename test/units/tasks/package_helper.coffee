Neat = require '../../../lib/neat'
Packager = require '../../../lib/tasks/package/packager'


Neat.config =
  tasks:
    package:
      conf: "#{Neat.root}/src/config/packages"
      dir: "#{Neat.root}/packages"
      tmp: "#{Neat.root}/.tmp"

global.packagerWithFiles = (files, operators, bare=false, block) ->
  [bare, block] = [null, bare] if typeof bare is 'function'

  describe.call this, "with [#{files}] as target", ->
    beforeEach ->
      @packager = new Packager
        name: 'fixtures'
        package: 'neat.fixtures'
        includes: files
        bare: bare
        operators: [
          'stripRequires'
          'annotateFile'
          'join'
          'exportsToPackage'
          'saveToFile'
        ]

      ended = false
      runs ->
        @packager.process =>
          @result = @packager.result
          ended = true

      waitsFor progress(-> ended), 'Timed out', 1000

    block?.call(this)

global.packagerWithFile = (file, bare=true, block) ->
  packagerWithFiles [file], bare, block
