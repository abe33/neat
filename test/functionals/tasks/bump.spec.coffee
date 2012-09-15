require '../../test_helper'
Neat = require '../../../lib/neat'
{run} = require '../../../lib/utils/commands'
{print} = require 'util'

options = {}
  # stderr: (data)-> print data
  # stdout: (data)-> print data

withBundledProject 'foo', ->
  describe 'running `cake bump`', ->
    it 'should bump the sources in the lib directory', (done) ->
      run 'cake', ['bump'], options, (status) ->
        expect(status).toBe(0)
        expect(inProject '.neat').toContain('version: "0.0.2"')
        expect(inProject 'package.json')
          .toContain('"version": "0.0.2"')
        done()

  describe 'running `cake bump:minor`', ->
    it 'should bump the sources in the lib directory', (done) ->
      run 'cake', ['bump:minor'], options, (status) ->
        expect(status).toBe(0)
        expect(inProject '.neat').toContain('version: "0.1.0"')
        expect(inProject 'package.json')
          .toContain('"version": "0.1.0"')
        done()

  describe 'running `cake bump:major`', ->
    it 'should bump the sources in the lib directory', (done) ->
      run 'cake', ['bump:major'], options, (status) ->
        expect(status).toBe(0)
        expect(inProject '.neat').toContain('version: "1.0.0"')
        expect(inProject 'package.json')
          .toContain('"version": "1.0.0"')
        done()

, init: (callback) ->
  args = [NEAT_BIN, 'generate', 'package.json']
  run 'node', args, options, (status) ->
    callback?()
