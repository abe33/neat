require '../../../test_helper'
Neat = require '../../../../lib/neat'
{run} = require '../../../../lib/utils/commands'
{print} = require 'util'
fs = require 'fs'

testSimpleGenerator 'config:packager', 'config/packages', '.cup'

options = {}
  # stderr: (data)-> print data
  # stdout: (data)-> print data

describe 'when outside a project', ->
  beforeEach ->
    process.chdir FIXTURES_ROOT
    addFileMatchers this

  describe 'running `neat generate config:packager:compile`', ->

    it "should return a status of 1 and don't generate anything", ->
      ended = false
      runs ->
        args = [NEAT_BIN, 'generate', 'config:packager:compile']
        run 'node', args, options, (status) ->
          expect(status).toBe(1)
          expect("#{FIXTURES_ROOT}/config/packages/compile.cup").not.toExist()
          ended = true

      waitsFor progress(-> ended), 'Timed out', 10000

withProject 'neat_project', ->
  describe 'running `neat generate config:packager:compile`', ->
    args = [
      NEAT_BIN,
      'generate',
      'config:packager:compile',
    ]

    it 'should generate a default config for compilation', (done) ->
      run 'node', args, (status) ->
        expect(inProject 'config/packages/compile.cup').toExist()
        done()
, init: (callback) ->
  fs.unlink inProject('config/packages/compile.cup'), callback
