require '../../test_helper'
Neat = require '../../../lib/neat'
{run} = require '../../../lib/utils/commands'

withBundledProject 'foo', ->

  describe 'setting hooks on commands', ->
    afterEach ->
      run 'rm', ['-rf', @projectPath]

    beforeEach ->

      commandPath = inProject('src/commands/foo.cmd.coffee')
      commandContent =  """
        Neat = require 'neat'
        fs = require 'fs'
        {run, aliases} = Neat.require 'utils/commands'
        {error, info, green, red, puts} = Neat.require 'utils/logs'

        exports['foo'] = (pr) ->
          aliases 'foo', (args..., callback) ->
            stream = fs.createWriteStream("\#{Neat.root}/test.log", flags:"a")
            stream.write "command called\\n", -> callback?()
        """

      hooksPath = inProject('src/config/initializers/hooks.coffee')
      hooksContent = """
        Neat = require 'neat'
        fs = require 'fs'

        module.exports = (config) ->
          stream = fs.createWriteStream("\#{Neat.root}/test.log", flags:"a")
          stream.write "hooks added\\n"

          Neat.beforeCommand.add (callback) ->
            stream = fs.createWriteStream("\#{Neat.root}/test.log", flags:"a")
            stream.write "beforeCommand called\\n", -> callback?()
          Neat.afterCommand.add (callback) ->
            stream = fs.createWriteStream("\#{Neat.root}/test.log", flags:"a")
            stream.write "afterCommand called\\n", -> callback?()
        """

      ended = false
      runs ->
        withCompiledFile commandPath, commandContent, ->
          withCompiledFile hooksPath, hooksContent, ->
            ended = true

      waitsFor progress(-> ended), 'Timed out', 10000

    describe 'and running neat foo', ->
      it 'should trigger the hooks', ->
        ended = false
        runs ->
          run 'node', [NEAT_BIN, 'foo'], (status) ->
            expect(status).toBe(0)
            expect(inProject 'test.log')
              .toContain("""hooks added
                            beforeCommand called
                            command called
                            afterCommand called""")
            ended = true

        waitsFor progress(-> ended), 'neat foo timed out', 10000

    describe 'and running neat help', ->
      it 'should trigger the hooks', ->
        ended = false
        runs ->
          run 'node', [NEAT_BIN, 'help'], (status) ->
            expect(status).toBe(0)
            expect(inProject 'test.log')
              .toContain("""hooks added
                            beforeCommand called
                            afterCommand called""")
            ended = true

        waitsFor progress(-> ended), 'Timed out', 10000

    describe 'and running neat generate command bar', ->
      it 'should trigger the hooks', ->
        ended = false
        runs ->
          run 'node', [NEAT_BIN, 'generate', 'command', 'bar'], (status) ->
            expect(status).toBe(0)
            expect(inProject 'test.log')
              .toContain("""hooks added
                            beforeCommand called
                            afterCommand called""")
            ended = true

        waitsFor progress(-> ended), 'Timed out', 10000

    describe 'and running neat generate task foo', ->
      it 'should trigger the hooks', ->
        ended = false
        runs ->
          run 'node', [NEAT_BIN, 'generate', 'task', 'foo'], (status) ->
            expect(status).toBe(0)
            expect(inProject 'test.log')
              .toContain("""hooks added
                            beforeCommand called
                            afterCommand called""")
            ended = true

        waitsFor progress(-> ended), 'Timed out', 10000

    describe 'and running neat generate initializer foo', ->
      it 'should trigger the hooks', ->
        ended = false
        runs ->
          run 'node', [NEAT_BIN, 'generate', 'initializer', 'foo'], (status) ->
            expect(status).toBe(0)
            expect(inProject 'test.log')
              .toContain("""hooks added
                            beforeCommand called
                            afterCommand called""")
            ended = true

        waitsFor progress(-> ended), 'Timed out', 10000

    describe 'and running neat generate generator foo', ->
      it 'should trigger the hooks', ->
        ended = false
        runs ->
          run 'node', [NEAT_BIN, 'generate', 'generator', 'foo'], (status) ->
            expect(status).toBe(0)
            expect(inProject 'test.log')
              .toContain("""hooks added
                            beforeCommand called
                            afterCommand called""")
            ended = true

        waitsFor progress(-> ended), 'Timed out', 10000

    describe 'and running neat generate spec:unit foo', ->
      it 'should trigger the hooks', ->
        ended = false
        runs ->
          run 'node', [NEAT_BIN, 'generate', 'spec:unit', 'foo'], (status) ->
            expect(status).toBe(0)
            expect(inProject 'test.log')
              .toContain("""hooks added
                            beforeCommand called
                            afterCommand called""")
            ended = true

        waitsFor progress(-> ended), 'Timed out', 10000

    describe 'and running neat generate spec:functional foo', ->
      it 'should trigger the hooks', ->
        ended = false
        runs ->
          run 'node',[NEAT_BIN,'generate','spec:functional','foo'], (status) ->
            expect(status).toBe(0)
            expect(inProject 'test.log')
              .toContain("""hooks added
                            beforeCommand called
                            afterCommand called""")
            ended = true

        waitsFor progress(-> ended), 'Timed out', 10000

    describe 'and running neat generate package.json', ->
      it 'should trigger the hooks', ->
        ended = false
        runs ->
          run 'node', [NEAT_BIN, 'generate', 'package.json'], (status) ->
            expect(status).toBe(0)
            expect(inProject 'test.log')
              .toContain("""hooks added
                            beforeCommand called
                            afterCommand called""")
            ended = true

        waitsFor progress(-> ended), 'Timed out', 10000

    describe 'and running neat generate config:lint foo', ->
      it 'should trigger the hooks', ->
        ended = false
        runs ->
          run 'node', [NEAT_BIN, 'generate', 'config:lint', 'foo'], (status) ->
            expect(status).toBe(0)
            expect(inProject 'test.log')
              .toContain("""hooks added
                            beforeCommand called
                            afterCommand called""")
            ended = true

        waitsFor progress(-> ended), 'Timed out', 10000

    describe 'and running neat generate config:packager foo', ->
      it 'should trigger the hooks', ->
        ended = false
        runs ->
          run 'node',[NEAT_BIN,'generate','config:packager','foo'], (status) ->
            expect(status).toBe(0)
            expect(inProject 'test.log')
              .toContain("""hooks added
                            beforeCommand called
                            afterCommand called""")
            ended = true

        waitsFor progress(-> ended), 'Timed out', 10000

    describe 'and running neat install', ->
      it 'should trigger the hooks', ->
        ended = false
        runs ->
          run 'node', [NEAT_BIN, 'install'], (status) ->
            expect(status).toBe(0)
            expect(inProject 'test.log')
              .toContain("""hooks added
                            beforeCommand called
                            afterCommand called""")
            ended = true

        waitsFor progress(-> ended), 'Timed out', 60000

, noCleaning: true
