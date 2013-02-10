require '../../test_helper'
Neat = require '../../../lib/neat'
{run} = require '../../../lib/utils/commands'
{print} = require 'util'

options = {}
  # stderr: (data)-> print data
  # stdout: (data)-> print data

describe 'when outside a project', ->
  beforeEach -> process.chdir TEST_TMP_DIR

  describe 'running `neat install`', ->
    it "should return a status of 1 and don't install anything", ->
      ended = false
      runs ->
        run 'node', [NEAT_BIN, 'install'], options, (status) ->
          expect(status).toBe(1)
          ended = true

      waitsFor progress(-> ended), 'Timed out', 10000

withProject 'neat_project', ->
  afterEach ->
    run 'rm', ['-rf', @projectPath]

  describe 'running `neat install`', ->
    it 'should install the dependencies', ->
      runs ->
        ended = false
        run 'node', [NEAT_BIN, 'install'], options, (status) ->
          expect(status).toBe(0)
          expect(inProject 'node_modules/neat').toExist()
          expect(inProject 'package.json').toExist()
          ended = true

        waitsFor progress(-> ended), 'Timed out', 50000
, noCleaning: true
