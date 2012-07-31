require '../../../test_helper'
Neat = require '../../../../lib/neat'
{run} = require '../../../../lib/utils/commands'

withProject 'foo', ->
  describe 'running `neat generate spec:unit foo`', ->
    it 'should generate a new spec foo in the project', (done) ->
      run 'node', [NEAT_BIN, 'generate', 'spec:unit', 'foo'], (status) ->
        path = inProject "test/units/foo.spec.coffee"
        expect(path).toExist()
        expect(path).toContain("describe 'foo', ->")
        expect(path).toContain("require '../test_helper'")

        done()

  describe 'running `neat generate spec:unit bar/foo`', ->
    it 'should generate a new spec foo in the project', (done) ->
      run 'node', [NEAT_BIN, 'generate', 'spec:unit', 'bar/foo'], (status) ->
        path = inProject "test/units/bar/foo.spec.coffee"
        expect(path).toExist()
        expect(path).toContain("describe 'foo', ->")
        expect(path).toContain("require '../../test_helper'")

        done()

  describe 'running `neat generate spec:functional foo`', ->
    it 'should generate a new spec foo in the project', (done) ->
      run 'node', [NEAT_BIN, 'generate', 'spec:functional', 'foo'], (status) ->
        path = inProject "test/functionals/foo.spec.coffee"
        expect(path).toExist()
        expect(path).toContain("describe 'foo', ->")
        expect(path).toContain("require '../test_helper'")

        done()

  describe 'running `neat generate spec:functional bar/foo`', ->
    it 'should generate a new spec foo in the project', (done) ->
      args = [NEAT_BIN, 'generate', 'spec:functional', 'bar/foo']
      run 'node', args, (status) ->
        path = inProject "test/functionals/bar/foo.spec.coffee"
        expect(path).toExist()
        expect(path).toContain("describe 'foo', ->")
        expect(path).toContain("require '../../test_helper'")

        done()

  describe 'running `neat generate spec:integration foo`', ->
    it 'should generate a new spec foo in the project', (done) ->
      args = [NEAT_BIN, 'generate', 'spec:integration', 'foo']
      run 'node', args, (status) ->
        path = inProject "test/integrations/foo.spec.coffee"
        expect(path).toExist()
        expect(path).toContain("describe 'foo', ->")
        expect(path).toContain("require '../test_helper'")

        done()

  describe 'running `neat generate spec:integration bar/foo`', ->
    it 'should generate a new spec foo in the project', (done) ->
      args = [NEAT_BIN, 'generate', 'spec:integration', 'bar/foo']
      run 'node', args, (status) ->
        path = inProject "test/integrations/bar/foo.spec.coffee"
        expect(path).toExist()
        expect(path).toContain("describe 'foo', ->")
        expect(path).toContain("require '../../test_helper'")

        done()
