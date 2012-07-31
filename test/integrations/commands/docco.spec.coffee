require '../../test_helper'
Neat = require '../../../lib/neat'
{run} = require '../../../lib/utils/commands'
{touch, ensurePath} = require '../../../lib/utils/files'
{print} = require 'util'

options = {}
  # stderr: (data)-> print data
  # stdout: (data)-> print data

withBundledProject 'foo', ->
  afterEach ->
    run 'rm', ['-rf', @projectPath]

  describe 'running `neat docco`', ->
    it 'should generate the documentation', ->
      runs ->
        ended = false
        run 'node', [NEAT_BIN, 'docco'], options, (status) ->
          expect(status).toBe(0)
          expect(inProject 'docs/src_commands_foo.cmd.html').toExist()
          expect(inProject 'docs/src_config_initializers_docco.html')
            .toExist()
          ended = true

        waitsFor progress(-> ended), 'Timed out', 50000
, noCleaning: true, init: (callback) ->
  args = [NEAT_BIN, 'generate', 'command', 'foo']
  run 'node', args, options, (status) ->
    run 'cake', ['compile'], options, (status) ->
      ensurePath inProject('src/config/initializers'), ->
        callback?()
