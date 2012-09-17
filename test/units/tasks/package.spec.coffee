require '../../test_helper'
require './package_helper'
Neat = require '../../../lib/neat'
Package = require '../../../lib/tasks/package/packager'

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


  describe 'when instanciated', ->

    it 'without name should throw an error', ->
      conf =
        includes: []
        operators: []
        package: 'foo'

      expect(-> new Packager conf).toThrow()

    it 'without package should throw an error', ->
      conf =
        name: 'foo'
        includes: []
        operators: []

      expect(-> new Packager conf).toThrow()


    it 'without includes should throw an error', ->
      conf =
        name: 'foo'
        package: 'foo'
        operators: []

      expect(-> new Packager conf).toThrow()

    it 'without operators should throw an error', ->
      conf =
        name: 'foo'
        includes: []
        package: 'foo'

      expect(-> new Packager conf).toThrow()

    it 'with invalid name should throw an error', ->
      conf =
        name: "fo[of]"
        package: 'foo'
        includes: []
        operators: []

      expect(-> new Packager conf).toThrow()

    it 'with invalid package should throw an error', ->
      conf =
        name: "foo"
        package: 'foo-bar.baz'
        includes: []
        operators: []

      expect(-> new Packager conf).toThrow()

    it 'with invalid includes should throw an error', ->
      conf =
        name: "foo"
        package: 'foo'
        includes: 10
        operators: []

      expect(-> new Packager conf).toThrow()

    it 'with invalid operators should throw an error', ->
      conf =
        name: "foo"
        package: 'foo'
        includes: []
        operators: 10

      expect(-> new Packager conf).toThrow()
