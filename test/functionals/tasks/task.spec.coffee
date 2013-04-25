require '../../test_helper'
Neat = require '../../../lib/neat'
{run} = Neat.require 'utils/commands'
{print} = require 'util'

options = {}
  # stderr: (data)-> print data
  # stdout: (data)-> print data

withBundledProject 'foo', ->

  describe 'setting hooks on tasks', ->
    beforeEach ->

      taskPath = inProject('src/tasks/foo.cake.coffee')
      taskContent =  """
        Neat = require 'neat'
        fs = require 'fs'
        {run, neatTask} = Neat.require 'utils/commands'
        {error, info, green, red, puts} = Neat.require 'utils/logs'

        exports['foo'] = neatTask
          name: 'foo'
          action: (callback) ->
            stream = fs.createWriteStream("\#{Neat.root}/test.log", flags:"a")
            stream.write "task called\\n", -> callback? 0
        """

      hooksPath = inProject('src/config/initializers/hooks.coffee')
      hooksContent = """
        Neat = require 'neat'
        fs = require 'fs'

        module.exports = (config) ->
          stream = fs.createWriteStream("\#{Neat.root}/test.log", flags:"a")
          stream.write "hooks added\\n"

          Neat.beforeTask.add (callback) ->
            stream = fs.createWriteStream("\#{Neat.root}/test.log", flags: "a")
            stream.write "beforeTask called\\n", -> callback?()

          Neat.afterTask.add (status, callback) ->
            stream = fs.createWriteStream("\#{Neat.root}/test.log", flags:"a")
            stream.write "afterTask called\\n", -> callback?()
        """

      ended = false
      runs ->
        withCompiledFile taskPath, taskContent, ->
          withCompiledFile hooksPath, hooksContent, ->
            run 'node', [NEAT_BIN, 'g', 'config:packager:compile'], options, ->
              ended = true

      waitsFor progress(-> ended), 'hooks compilation', 20000

    describe 'and running cake test', ->
      it 'should trigger the hooks', ->
        ended = false
        runs ->
          run 'cake', ['test'], options, (status) ->
            expect(status).toBe(0)
            expect(inProject 'test.log')
              .toContain("""hooks added
                            beforeTask called
                            afterTask called""")
            ended = true

        waitsFor progress(-> ended), 'cake test timed out', 20000

    describe 'and running cake lint', ->
      it 'should trigger the hooks', ->
        ended = false
        runs ->
          run 'cake', ['lint'], options, (status) ->
            expect(status).toBe(0)
            expect(inProject 'test.log')
              .toContain("""hooks added
                            beforeTask called
                            afterTask called""")
            ended = true

        waitsFor progress(-> ended), 'cake lint timed out', 20000

    describe 'and running cake foo', ->
      it 'should trigger the hooks', ->
        ended = false
        runs ->
          run 'cake', ['foo'], options, (status) ->
            expect(status).toBe(0)
            expect(inProject 'test.log')
              .toContain("""hooks added
                            beforeTask called
                            task called
                            afterTask called""")
            ended = true

        waitsFor progress(-> ended), 'cake foo timed out', 20000

    describe 'and running cake bump', ->
      it 'should trigger the hooks', ->
        ended = false
        runs ->
          run 'cake', ['bump'], options, (status) ->
            expect(status).toBe(0)
            expect(inProject 'test.log')
              .toContain("""hooks added
                            beforeTask called
                            afterTask called""")

            ended = true

        waitsFor progress(-> ended), 'cake bumb timed out', 20000


    describe 'and running cake bump:minor', ->
      it 'should trigger the hooks', ->
        ended = false
        runs ->
          run 'cake', ['bump:minor'], options, (status) ->
            expect(status).toBe(0)
            expect(inProject 'test.log')
              .toContain("""hooks added
                            beforeTask called
                            afterTask called""")
            ended = true

        waitsFor progress(-> ended), 'cake bumb:minor timed out', 20000

    describe 'and running cake bump:major', ->
      it 'should trigger the hooks', ->
        ended = false
        runs ->
          run 'cake', ['bump:major'], options, (status) ->
            expect(status).toBe(0)
            expect(inProject 'test.log')
              .toContain("""hooks added
                            beforeTask called
                            afterTask called""")
            ended = true

        waitsFor progress(-> ended), 'cake bumb:major timed out', 20000

    describe 'and running cake compile', ->
      it 'should trigger the hooks', ->
        ended = false
        runs ->
          run 'cake', ['compile'], options, (status) ->
            expect(status).toBe(0)
            expect(inProject 'test.log')
              .toContain("""hooks added
                            beforeTask called
                            afterTask called""")
            ended = true

        waitsFor progress(-> ended), 'cake compile timed out', 20000

    describe 'and running cake version', ->
      it 'should trigger the hooks', ->
        ended = false
        runs ->
          run 'cake', ['version'], options, (status) ->
            expect(status).toBe(0)
            expect(inProject 'test.log')
              .toContain("""hooks added
                            beforeTask called
                            afterTask called""")
            ended = true

        waitsFor progress(-> ended), 'cake version timed out', 20000


