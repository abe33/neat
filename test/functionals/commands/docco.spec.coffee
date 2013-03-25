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
      ended = false
      runs ->
        run 'node', [NEAT_BIN, 'docco'], options, (status) ->
          expect(status).toBe(0)
          expect(inProject 'docs/docco.css').toExist()
          expect(inProject 'docs/src_commands_foo.cmd.html').toExist()
          ended = true

      waitsFor progress(-> ended), 'Timed out on neat docco', 10000

  describe 'running `neat docco:stylesheet`', ->
    it 'should generate the documentation stylesheet ', ->
      ended = false
      runs ->
        run 'node', [NEAT_BIN, 'docco:stylesheet'], options, (status) ->
          expect(status).toBe(0)
          expect(inProject 'docs/docco.css').toExist()
          expect(inProject 'docs/docco.js').not.toExist()
          expect(inProject 'docs/src_commands_foo.cmd.html').not.toExist()
          ended = true

      waitsFor progress(-> ended), 'Timed out on neat docco:stylesheet', 10000

  describe 'running `neat docco:javascript`', ->
    it 'should generate the documentation javascript ', ->
      ended = false
      runs ->
        run 'node', [NEAT_BIN, 'docco:javascript'], options, (status) ->
          expect(status).toBe(0)
          expect(inProject 'docs/docco.js').toExist()
          expect(inProject 'docs/docco.css').not.toExist()
          expect(inProject 'docs/src_commands_foo.cmd.html').not.toExist()
          ended = true

      waitsFor progress(-> ended), 'Timed out on neat docco:javascript', 10000

  describe 'running `neat docco:documentation`', ->
    it 'should generate the documentation stylesheet ', ->
      ended = false
      runs ->
        run 'node', [NEAT_BIN, 'docco:documentation'], options, (status) ->
          expect(status).toBe(0)
          expect(inProject 'docs/docco.css').not.toExist()
          expect(inProject 'docs/docco.js').not.toExist()
          expect(inProject 'docs/src_commands_foo.cmd.html').toExist()
          ended = true

      waitsFor progress(-> ended), 'Timed out on docco:documentation', 10000

, noCleaning: true, init: (callback) ->
  args = [NEAT_BIN, 'generate', 'command', 'foo']
  run 'node', args, options, (status) ->
    run 'cake', ['compile'], options, (status) ->
      callback?()
