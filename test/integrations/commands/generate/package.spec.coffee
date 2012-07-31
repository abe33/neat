require '../../../test_helper'
Neat = require '../../../../lib/neat'
{run} = require '../../../../lib/utils/commands'

withProject 'foo', ->
  describe 'running `neat generate package`', ->
    args = [
      NEAT_BIN,
      'generate',
      'package',
    ]
    it 'should generate a package.json file at the project root', (done) ->
      run 'node', args, (status) ->
        path = inProject "package.json"
        expect(path).toExist()
        expect(path).toContain('"name": "foo"')
        expect(path).toContain('"version": "0.0.1"')
        expect(path).toContain('"author": "John Doe"')
        expect(path).toContain('"description": "a description"')

        expect(path).toContain("\"neat\": \"#{Neat.meta.version}\"")

        kw = "\"keywords\": [\n    \"foo\",\n    \"bar\",\n    \"baz\"\n  ]"
        expect(path).toContain(kw)

        done()
