require '../../test_helper'
Neat = require '../../../lib/neat'
{run} = require '../../../lib/utils/commands'

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
            fs.createWriteStream("\#{Neat.root}/test.log", flags:"a")
              .write "task called\\n"
            callback?()
        """

      hooksPath = inProject('src/config/initializers/hooks.coffee')
      hooksContent = """
        Neat = require 'neat'
        fs = require 'fs'

        module.exports = (config) ->
          fs.createWriteStream("\#{Neat.root}/test.log", flags:"a")
            .write "hooks added\\n"

          Neat.beforeTask.add ->
            fs.createWriteStream("\#{Neat.root}/test.log", flags:"a")
              .write "beforeTask called\\n"
          Neat.afterTask.add ->
            fs.createWriteStream("\#{Neat.root}/test.log", flags:"a")
              .write "afterTask called\\n"
        """

      ended = false
      runs ->
        withCompiledFile taskPath, taskContent, ->
          withCompiledFile hooksPath, hooksContent, ->
            ended = true

      waitsFor progress(-> ended), 'hooks compilation', 5000

    describe 'and running cake test', ->
      it 'should trigger the hooks', (done) ->

        run 'cake', ['test'], (status) ->
          expect(status).toBe(0)
          expect(inProject 'test.log')
            .toContain("""hooks added
                          beforeTask called
                          afterTask called""")
          done()

    describe 'and running cake lint', ->
      it 'should trigger the hooks', ->
        ended = false
        runs ->
          run 'cake', ['lint'], (status) ->
            expect(status).toBe(0)
            expect(inProject 'test.log')
              .toContain("""hooks added
                            beforeTask called
                            afterTask called""")
            ended = true

        waitsFor progress(-> ended), 'cake lint timed out', 5000

    describe 'and running cake foo', ->
      it 'should trigger the hooks', ->
        ended = false
        runs ->
          run 'cake', ['foo'], (status) ->
            expect(status).toBe(0)
            expect(inProject 'test.log')
              .toContain("""hooks added
                            beforeTask called
                            task called
                            afterTask called""")
            ended = true

        waitsFor progress(-> ended), 'cake foo timed out', 5000

    describe 'and running cake bump', ->
      it 'should trigger the hooks', ->
        ended = false
        runs ->
          run 'cake', ['bump'], (status) ->
            expect(status).toBe(0)
            expect(inProject 'test.log')
              .toContain("""hooks added
                            beforeTask called
                            afterTask called""")

            ended = true

        waitsFor progress(-> ended), 'cake bumb timed out', 5000


    describe 'and running cake bump:minor', ->
      it 'should trigger the hooks', ->
        ended = false
        runs ->
          run 'cake', ['bump:minor'], (status) ->
            expect(status).toBe(0)
            expect(inProject 'test.log')
              .toContain("""hooks added
                            beforeTask called
                            afterTask called""")
            ended = true

        waitsFor progress(-> ended), 'cake bumb:minor timed out', 5000

    describe 'and running cake bump:major', ->
      it 'should trigger the hooks', ->
        ended = false
        runs ->
          run 'cake', ['bump:major'], (status) ->
            expect(status).toBe(0)
            expect(inProject 'test.log')
              .toContain("""hooks added
                            beforeTask called
                            afterTask called""")
            ended = true

        waitsFor progress(-> ended), 'cake bumb:major timed out', 5000

    describe 'and running cake compile', ->
      it 'should trigger the hooks', ->
        ended = false
        runs ->
          run 'cake', ['compile'], (status) ->
            expect(status).toBe(0)
            expect(inProject 'test.log')
              .toContain("""hooks added
                            beforeTask called
                            afterTask called""")
            ended = true

        waitsFor progress(-> ended), 'cake compile timed out', 5000

    describe 'and running cake version', ->
      it 'should trigger the hooks', ->
        ended = true
        runs ->
          run 'cake', ['version'], (status) ->
            expect(status).toBe(0)
            expect(inProject 'test.log')
              .toContain("""hooks added
                            beforeTask called
                            afterTask called""")
            ended = true

        waitsFor progress(-> ended), 'cake version timed out', 5000


