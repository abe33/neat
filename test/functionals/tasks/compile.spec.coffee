require '../../test_helper'
Neat = require '../../../lib/neat'
{run} = require '../../../lib/utils/commands'

withBundledProject 'foo', ->
  describe 'running `cake compile`', ->
    it 'should compile the sources in the lib directory', (done) ->
      run 'cake', ['compile'], (status) ->
        expect(status).toBe(0)
        done()

  describe 'setting hooks on compilation', ->
    beforeEach ->

      hooksPath = inProject('src/config/initializers/hooks.coffee')
      hooksContent = """
        Neat = require 'neat'
        fs = require 'fs'

        module.exports = (config) ->
          fs.createWriteStream("\#{Neat.root}/test.log", flags:"a")
            .write "hooks added\\n"

          Neat.beforeCompilation.add ->
            fs.createWriteStream("\#{Neat.root}/test.log", flags:"a")
              .write "beforeCompilation called\\n"
          Neat.afterCompilation.add ->
            fs.createWriteStream("\#{Neat.root}/test.log", flags:"a")
              .write "afterCompilation called\\n"
        """

      ended = false
      runs ->
        withCompiledFile hooksPath, hooksContent, ->
          ended = true

      waitsFor progress(-> ended), 'Timed out', 1000

    # FIXME compilation hooks are disabled until a better solution is found
    xdescribe 'and running cake compile', ->
      it 'should trigger the hooks', (done) ->
        run 'cake', ['compile'], (status) ->
          expect(status).toBe(0)
          expect(inProject 'test.log')
            .toContain("""hooks added
                          beforeCompilation called
                          afterCompilation called""")
          done()

