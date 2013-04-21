fs = require 'fs'
Q = require 'q'
Neat = require '../../../../lib/neat'
commands = Neat.require 'utils/commands'

global.withBuildSpies = (block) ->
  describe '', ->
    beforeEach ->
      addPromiseMatchers this
      safeReadFile = fs.readFile
      spyOn(fs, 'readFile').andCallFake (path, callback) ->
        switch path
          when Neat.resolve 'Neatfile'
            callback null, '''
              build 'lib', (b) ->
                b.source 'test/fixtures/tasks/build/*.coffee'
                b.source 'test/fixtures/tasks/build/some_file_2.coffee'

                b.do(compile bare: true)
                .then(relocate 'test/fixtures', 'lib')
                .then(writeFiles)
            '''

          when Neat.resolve 'test/fixtures/tasks/build/some_file_1.coffee'
            safeReadFile path, callback

          when Neat.resolve 'test/fixtures/tasks/build/some_file_2.coffee'
            safeReadFile path, callback

          else
            callback null, ''

      spyOn(fs, 'writeFile').andCallFake (path, content, callback) ->
        callback? null


    block.call this
