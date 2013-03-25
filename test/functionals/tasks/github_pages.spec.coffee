{print} = require 'util'
{exec} = require 'child_process'

require '../../test_helper'
Neat = require '../../../lib/neat'
{run} = require '../../../lib/utils/commands'

options = {}

withBundledProject 'neat_project', ->
  withPagesInitialized ->
    withGitInitialized ->
      describe 'running cake github:pages', ->
        beforeEach ->
          addFileMatchers this

          ended = false
          runs ->
            exec 'git status; cake github:pages; git branch', (e,s,se) ->
              throw e if e?
              ended = true

          waitsFor progress(-> ended), 'Timed out on pages creation', 5000

        git.should.haveBranch('gh-pages')
        git.should.beInBranch('master')

        git.inBranch 'gh-pages', ->
          git.should.not.haveUnstagedChange()
          git.should.not.haveUntrackedFiles()

          it 'should have an index.html file', ->
            expect(inProject 'index.html').toExist()
            expect(inProject 'index.html')
            .toContain("<title>neat_project - Hello World</title>")

          it 'should have a pages.css file', ->
            expect(inProject 'pages.css').toExist()

          it 'should have docs directory', ->
            expect(inProject 'docs').toExist()

          it 'should have removed all the git content', ->
            expect(inProject '.pages').not.toExist()
            expect(inProject 'src').not.toExist()
            expect(inProject 'lib').not.toExist()
            expect(inProject 'test').not.toExist()
            expect(inProject 'templates').not.toExist()
            expect(inProject 'pages').not.toExist()
            expect(inProject 'config').not.toExist()
            expect(inProject 'Nemfile').not.toExist()
            expect(inProject 'Cakefile').not.toExist()
            expect(inProject '.npmignore').not.toExist()
            expect(inProject '.neat').not.toExist()
            expect(inProject 'package.json').not.toExist()

          it 'should have preserved all the other files and directory', ->
            expect(inProject 'node_modules').toExist()
            expect(inProject '.gitignore').toExist()

