require '../../test_helper'
require './package_helper'
Neat = require '../../../lib/neat'

op = require '../../../lib/tasks/package/operators'

{readFileSync} = require 'fs'

describe 'Packager', ->
  files = [
    "test/fixtures/tasks/package/require"
    "test/fixtures/tasks/package/exports"
  ]
  expected = "#{Neat.root}/test/fixtures/tasks/package/expected.coffee"
  operators = [
    op.stripRequires
    op.annotate
    op.join
    op.exportsToPackage
    op.saveToFile
  ]
  packagerWithFiles.call this, files, operators, ->
    beforeEach -> addFileMatchers this
    it 'should apply the operators on the file', ->
      path = "#{Neat.root}/packages/fixtures.coffee"
      expected = String(readFileSync expected)
        .squeeze('\n')
        .strip()
        .replace /\#\{file\[(\d+)\]\}/g, (m,n) ->
          "#{Neat.root}/#{files[parseInt n]}.coffee"

      expect(@result[path].squeeze('\n').strip()).toEqual(expected)

