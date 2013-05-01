require '../../../test_helper'
fs = require 'fs'
Neat = require '../../../../lib/neat'
Builder = Neat.require 'tasks/build/builder'

describe 'Builder', ->
  withBuildSpies ->
    subject 'builder', -> new Builder

    it 'should exist', ->
      expect(@builder).toBeDefined()

    describe '::init', ->

      subject 'promise', -> @builder.init()

      waiting -> @promise

      promise()
      .should.beFulfilled()
      .should 'have processed the builds', ->
        expect(fs.writeFile).toHaveBeenCalled()

      describe 'once initialized', ->
        it 'should have created the corresponding builds', ->
          expect(@builder.builds.length).toBe(1)

        describe 'the created build', ->
          subject 'build', -> @builder.builds.first()

          it 'should contains the specified sources', ->
            expect(@build.sources).toEqual([
              Neat.rootResolve('test/fixtures/tasks/build/*.coffee')
              Neat.rootResolve('test/fixtures/tasks/build/some_file_2.coffee')
            ])

          it 'should contains the specified promises', ->
            expect(@build.processors.length).toBe(3)




