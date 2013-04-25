Neat = require '../../lib/neat'
Neat.require 'core'
{run} = Neat.require 'utils/commands'

options = {}
  # stderr: (data)-> print data
  # stdout: (data)-> print data

global.testSimpleGenerator= (name, dir, ext) ->
  describe 'when outside a project', ->
    beforeEach -> process.chdir TEST_TMP_DIR

    describe "running `neat generate #{name} 'foo'`", ->
      it "should return a status of 1 and don't generate anything", ->
        ended = false
        runs ->
          args = [NEAT_BIN, 'generate', name, 'foo']
          run 'node', args, options, (status) ->
            expect(status).toBe(1)
            ended = true

        waitsFor progress(-> ended), 'Timed out', 10000

  withProject 'neat_project', ->
    describe "running `neat generate #{name}`", ->
      it "should return a status of 1 and don't generate anything", ->
        ended = false
        runs ->
          run 'node', [NEAT_BIN, 'generate', name], options, (status) ->
            expect(status).toBe(1)
            ended = true

        waitsFor progress(-> ended), 'Timed out', 10000

    describe "running `neat generate #{name} foo`", ->
      it "should generate a new #{name} foo in the project", (done) ->
        run 'node', [NEAT_BIN, 'generate', name, 'foo'], (status) ->
          expect(inProject "#{dir}/foo#{ext}").toExist()

          done()

    describe "running `neat generate #{name} bar/foo`", ->
      it "should generate a new #{name} foo in the project", (done) ->
        run 'node', [NEAT_BIN, 'generate', name, 'bar/foo'], (status) ->
          expect(inProject "#{dir}/bar/foo#{ext}")
            .toExist()

          done()

    describe "with a file already existing at the same path", ->
      it "should return a status of 1 and don't generate anything", ->
        ended = false
        runs ->
          withSourceFile inProject("#{dir}/foo#{ext}"), 'original_content', ->
            args = [NEAT_BIN, 'generate', name, 'foo']
            run 'node', args, options, (status) ->
              expect(status).toBe(1)
              expect("#{dir}/foo#{ext}").toExist()
              expect("#{dir}/foo#{ext}").toContain('original_content')
              ended = true

          waitsFor progress(-> ended), 'Timed out', 10000
