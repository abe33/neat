{exec} = require 'child_process'

currentBranch = (status) ->
  status.split('\n').shift().replace /\# On branch (.+)$/gm, '$1'

hasUntrackedFile = (status) -> status.indexOf('Untracked files:') isnt -1
hasUnstagedChanges = (status) -> status.indexOf('Changes not staged') isnt -1

global.git =
  should:
    haveBranch: (branch) ->
      it "should have a branch #{branch}", ->
        ended = false
        runs ->
          exec 'git branch', (err, branches) ->
            throw err if err?
            branches = branches.split('\n').map (b) -> b[2..]
            branches.pop()
            expect(branch in branches).toBeTruthy()
            ended = true

        waitsFor progress(-> ended), 'Timed out on git branch', 1000
    beInBranch: (branch) ->
      it "should be in branch #{branch}", ->
        ended = false
        runs ->
          exec 'git status', (err, status) ->
            throw err if err?
            current = currentBranch status
            expect(current).toBe(branch)
            ended = true

        waitsFor progress(-> ended), 'Timed out on git status', 1000
    not:
      haveUnstagedChange: ->
        it "should not have unstaged changes", ->
          ended = false
          runs ->
            exec 'git status', (err, status) ->
              throw err if err?
              expect(hasUnstagedChanges status).toBeFalsy()
              ended = true

          waitsFor progress(-> ended), 'Timed out on git status', 1000

      haveUntrackedFiles: ->
        it "should not have untracked files", ->
          ended = false
          runs ->
            exec 'git status', (err, status) ->
              throw err if err?
              expect(hasUntrackedFile status).toBeFalsy()
              ended = true

          waitsFor progress(-> ended), 'Timed out on git status', 1000

  inBranch: (branch, block) ->
    describe "in branch #{branch}", ->
      beforeEach ->
        ended = false
        runs ->
          exec 'git checkout gh-pages', (err) ->
            throw err if err?
            ended = true

        waitsFor progress(-> ended), 'Timed out on git checkout gh-pages', 1000

      block.call this
