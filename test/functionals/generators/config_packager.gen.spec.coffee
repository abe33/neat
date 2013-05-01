require '../../test_helper'
Neat = require '../../../lib/neat'
{run} = Neat.require 'utils/commands'
{print} = require 'util'
fs = require 'fs'

options = {}
  # stderr: (data)-> print data
  # stdout: (data)-> print data

testSimpleGenerator 'config:packager', 'config/packages', '.cup'

describe 'when outside a project', ->
  beforeEach ->
    process.chdir TEST_TMP_DIR
    addFileMatchers this

  describe 'running `neat generate config:packager:compile`', ->

    it "should return a status of 1 and don't generate anything", ->
      ended = false
      runs ->
        args = [NEAT_BIN, 'generate', 'config:packager:compile']
        run 'node', args, options, (status) ->
          expect(status).toBe(1)
          expect("#{TEST_TMP_DIR}/config/packages/compile.cup").not.toExist()
          ended = true

      waitsFor progress(-> ended), 'Timed out', 10000

withBundledProject 'neat_project', ->
  describe 'running `neat generate config:packager:compile`', ->
    args = [NEAT_BIN, 'generate', 'config:packager:compile']

    it 'should generate a default config for compilation', (done) ->
      run 'node', args, options, (status) ->
        expect(inProject 'config/packages/compile.cup').toExist()
        done()
, init: (callback) ->
  fs.unlink inProject('config/packages/compile.cup'), callback
