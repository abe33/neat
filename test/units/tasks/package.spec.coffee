require '../../test_helper'
require '../../helpers/tasks/package_helper'
Neat = require '../../../lib/neat'
Packager = require '../../../lib/tasks/package/packager'

{readFileSync} = require 'fs'

describe 'Packager', ->


  files = [
    "test/fixtures/tasks/package/require"
    "test/fixtures/tasks/package/exports"
    "test/fixtures/tasks/package/class"
  ]
  exp = "#{Neat.root}/test/fixtures/tasks/package/expected.coffee"
  packagerWithFiles.call this, files, ->
    beforeEach -> addFileMatchers this
    it 'should apply the operators on the file', ->
      path = "#{Neat.root}/.tests/packages/directory/fixtures.coffee"
      repl = (m,n) -> "#{files[parseInt n]}.coffee"
      exp = String(readFileSync exp)
        .squeeze('\n')
        .strip()
        .replace /\#\{file\[(\d+)\]\}/g, repl

      expect(@result[path].squeeze('\n').strip()).toEqual(exp)
      expect(path).toExist()


  describe 'when instanciated', ->
    it 'without includes should throw an error', ->
      conf =
        operators: []

      expect(-> new Packager conf).toThrow()

    it 'without operators should throw an error', ->
      conf =
        includes: []

      expect(-> new Packager conf).toThrow()


    it 'with invalid includes should throw an error', ->
      conf =
        includes: 10
        operators: []

      expect(-> new Packager conf).toThrow()

    it 'with invalid operators should throw an error', ->
      conf =
        includes: []
        operators: 10

      expect(-> new Packager conf).toThrow()

describe 'exports:package operator', ->
  it 'without package should throw an error', ->
    conf =
      includes: []
      operators: ['exports:package']

    expect(-> new Packager conf).toThrow()

  it 'with invalid package should throw an error', ->
    conf =
      package: 'foo-bar.baz'
      includes: []
      operators: ['exports:package']

    expect(-> new Packager conf).toThrow()

describe 'create:directory operator', ->
  it 'without directory should throw an error', ->
    conf =
      includes: []
      operators: ['create:directory']

    expect(-> new Packager conf).toThrow()

describe 'join operator', ->
  it 'without name should throw an error', ->
    conf =
      includes: []
      operators: ['join']

    expect(-> new Packager conf).toThrow()

  it 'with invalid name should throw an error', ->
    conf =
      name: "fo[of]"
      includes: []
      operators: ['join']

    expect(-> new Packager conf).toThrow()
