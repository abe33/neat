require '../../test_helper'
require './package_helper'
Neat = require '../../../lib/neat'

{readFileSync} = require 'fs'

describe 'Packager', ->
  files = [
    "test/fixtures/tasks/package/require"
    "test/fixtures/tasks/package/exports"
    "test/fixtures/tasks/package/class"
  ]
  expected = "#{Neat.root}/test/fixtures/tasks/package/expected.coffee"
  packagerWithFiles.call this, files, ->
    beforeEach -> addFileMatchers this
    it 'should apply the operators on the file', ->
      path = "#{Neat.root}/packages/fixtures.coffee"
      repl = (m,n) -> "#{files[parseInt n]}.coffee"
      expected = String(readFileSync expected)
        .squeeze('\n')
        .strip()
        .replace /\#\{file\[(\d+)\]\}/g, repl

      expect(@result[path].squeeze('\n').strip()).toEqual(expected)

