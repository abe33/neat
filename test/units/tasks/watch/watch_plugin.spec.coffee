require '../../../test_helper'

fs = require 'fs'
Q = require 'q'
path = require 'path'
Neat = require '../../../../lib/neat'
Watch = Neat.require 'tasks/watch/watch'

describe 'WatchPlugin', ->
  subject 'plugin', -> new MockPlugin
  given 'watches', -> @plugin.watches
  given 'watch', -> new Watch /file\.coffee$/

  it 'should exist', ->
    expect(@plugin).toBeDefined()

  describe 'after creation', ->
    it 'should have an empty watches array', ->
      expect(@watches).toEqual([])

  describe '#watch', ->
    describe 'called with a watch', ->
      beforeEach -> @plugin.watch @watch

      it 'should add the watch to the watches list', ->
        expect(@watches).toContain @watch

  describe '#match', ->
    beforeEach -> @plugin.watch @watch

    describe 'called with a path that match one its watch', ->
      it 'should return true', ->
        expect(@plugin.match '/foo/file.coffee').toBeTruthy()
        expect(@plugin.match '/foo/bar/file.coffee').toBeTruthy()
        expect(@plugin.match '/foo/some_file.coffee').toBeTruthy()

    describe 'called with a path that does not match', ->
      it 'should return false', ->
        expect(@plugin.match '/foo/file.js').toBeFalsy()
        expect(@plugin.match '/foo/foo.coffee').toBeFalsy()
        expect(@plugin.match '/foo/file.coffee/foo').toBeFalsy()


