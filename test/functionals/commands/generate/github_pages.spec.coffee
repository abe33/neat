{print} = require 'util'
{exec} = require 'child_process'

require '../../../test_helper'
Neat = require '../../../../lib/neat'
{run} = require '../../../../lib/utils/commands'

options = {}

withBundledProject 'neat_project', ->
  withPagesInitialized ->
    describe 'running neat generate github:pages', ->
      beforeEach -> addFileMatchers this
      it 'should have created a pages.cup file in config', ->
        expect(inProject 'config/pages.cup').toExist()

      it 'should have created an index.md file in pages directory', ->
        expect(inProject 'pages/index.md').toExist()

      it 'should have created a pages.stylus file in pages directory', ->
        expect(inProject 'pages/pages.stylus').toExist()
