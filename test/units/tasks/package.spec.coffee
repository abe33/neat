require '../../test_helper'
require './package_helper'
Neat = require '../../../lib/neat'

{readFileSync} = require 'fs'

describe 'Packager', ->
  files = [
    "test/fixtures/tasks/package/require"
    "test/fixtures/tasks/package/exports"
  ]
  expected = "#{Neat.root}/test/fixtures/tasks/package/expected.coffee"
  packagerWithFiles files, ->
    beforeEach -> addFileMatchers this
    it 'should replace exports with the package', ->
      expected = String(readFileSync expected)
        .squeeze('\n')
        .strip()
        .replace /\#\{file\[(\d+)\]\}/g, (m,n) ->
          "#{Neat.root}/#{files[parseInt n]}.coffee"
      expect(@result.squeeze('\n').strip()).toEqual(expected)

