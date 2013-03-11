require '../../../test_helper'
Neat = require '../../../../lib/neat'
{run} = require '../../../../lib/utils/commands'
{print} = require 'util'

options = {}
  # stderr: (data)-> print data
  # stdout: (data)-> print data

describe 'when outside a project', ->
  beforeEach ->
    process.chdir TEST_TMP_DIR
    addFileMatchers this

  describe 'running `neat generate package.json`', ->

    it "should return a status of 1 and don't generate anything", ->
      ended = false
      runs ->
        args = [NEAT_BIN, 'generate', 'package.json']
        run 'node', args, options, (status) ->
          expect(status).toBe(1)
          expect("#{TEST_TMP_DIR}/package.json").not.toExist()
          ended = true

      waitsFor progress(-> ended), 'Timed out', 10000

withProject 'neat_project', ->
  describe 'running `neat generate package.json`', ->
    args = [
      NEAT_BIN,
      'generate',
      'package.json',
    ]
    it 'should generate a package.json file at the project root', (done) ->
      run 'node', args, (status) ->
        path = inProject "package.json"
        expect(path).toExist()
        expect(path).toContain('"name": "neat_project"')
        expect(path).toContain('"version": "0.0.1"')
        expect(path).toContain('"author": "John Doe"')
        expect(path).toContain('"description": "a description"')

        expect(path).toContain("\"neat\": \"#{Neat.meta.version}\"")

        kw = "\"keywords\": [\n    \"foo\",\n    \"bar\",\n    \"baz\"\n  ]"
        expect(path).toContain(kw)

        done()
