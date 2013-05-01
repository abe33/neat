require '../../../test_helper'

fs = require 'fs'
Build = require '../../../../lib/tasks/build/build'
Neat = require '../../../../lib/neat'
processors = Neat.require 'processing'

describe 'Build', ->
  subject 'build', -> new Build 'irrelevant'

  it 'should exist', ->
    expect(@build).toBeDefined()

  describe 'after creation', ->
    it 'should have a name', ->
      expect(@build.name).toBe('irrelevant')

    it 'should have a sources array', ->
      expect(@build.sources).toEqual([])

    it 'should have a processors array', ->
      expect(@build.processors).toEqual([])

  describe '::source', ->
    describe 'when called with a path', ->
      beforeEach ->
        @build.source 'some/path/to/a/file'

      it 'should store the path in the sources', ->
        expect(@build.sources)
        .toContain(Neat.rootResolve 'some/path/to/a/file')

  describe '::do', ->
    describe 'when called with a parameter', ->
      given 'processor', -> (buffer) ->
      beforeEach ->
        @result = @build.do @processor

      it 'should have stored the processor', ->
        expect(@build.processors).toContain(@processor)

      it 'should have returned itself', ->
        expect(@result).toBe(@build)

  describe '::toSource', ->
    it 'should return the build name', ->
      expect(@build.toString()).toBe('[Build: irrelevant]')

  describe '::findSources', ->
    beforeEach ->
      @build.source fixture 'tasks/build/**/*.coffee'
      @build.source fixture 'tasks/build/**/*.coffee'

    subject 'promise', -> @build.findSources()

    waiting -> @promise

    promise()
    .should.beFulfilled()
    .should.returns 'An array with paths', ->
      [
        fixture 'tasks/build/some_file_1.coffee'
        fixture 'tasks/build/some_file_2.coffee'
      ]

  describe '::loadBuffer', ->
    subject 'promise', -> @build.loadBuffer [
        fixture 'tasks/build/some_file_1.coffee'
        fixture 'tasks/build/some_file_2.coffee'
      ]

    waiting -> @promise

    promise()
    .should.beFulfilled()
    .should.returns 'a file buffer object', ->
      o = {}
      o[fixture 'tasks/build/some_file_1.coffee'] = 'foo = ->\n'
      o[fixture 'tasks/build/some_file_2.coffee'] = 'bar = ->\n'
      o

  describe '::processBuffer', ->
    given 'buffer', ->
      buffer = {}
      buffer[fixture 'tasks/build/some_file_1.coffee'] = 'foo = ->\n'
      buffer[fixture 'tasks/build/some_file_2.coffee'] = 'bar = ->\n'
      buffer

    withBuildSpies ->
      beforeEach ->
        @build.do processors.compile bare: true
        @build.do processors.relocate 'test/units/tasks/build', 'lib'
        @build.do processors.writeFiles

      subject 'promise', -> @build.processBuffer @buffer

      waiting -> @promise

      promise()
      .should.beFulfilled()
      .should 'write files to their destination', ->
        expect(fs.writeFile).toHaveBeenCalled()

  describe '::process', ->
    withBuildSpies ->
      beforeEach ->
        @build.source fixture 'tasks/build/**/*.coffee'
        @build.source fixture 'tasks/build/**/*.coffee'
        @build.do processors.compile bare: true
        @build.do processors.relocate 'test/units/tasks/build', 'lib'
        @build.do processors.writeFiles

      subject 'promise', -> @build.process()

      waiting -> @promise

      promise()
      .should.beFulfilled()
      .should 'write files to their destination', ->
        expect(fs.writeFile).toHaveBeenCalled()



