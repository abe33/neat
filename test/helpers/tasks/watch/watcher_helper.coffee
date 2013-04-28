fs = require 'fs'
growly = require 'growly'
notifySend = require 'notify-send'
rl = require 'readline'
Q = require 'q'
Neat = require '../../../../lib/neat'
WatchPlugin = Neat.require 'tasks/watch/watch_plugin'
Watch = Neat.require 'tasks/watch/watch'
commands = Neat.require 'utils/commands'

class MockPlugin extends WatchPlugin
  pathChanged: (path) -> => Q.fcall ->

global.MockPlugin = MockPlugin

global.addWatchesMatcher = (scope) ->
  scope.addMatchers
    isWatch: ->
      notText = if @isNot then " not" else ""
      @message = ->
        "Expected #{@actual}#{notText} to be a watch"

      @actual? and @actual.regexp? and @actual.options?

    toContainWatchFor: (re) ->
      notText = if @isNot then " not" else ""
      @message = ->
        "Expected [#{@actual}]#{notText} to contain a watch for #{re}"

      @actual? and @actual.some (o) -> o.regexp.toString() is re.toString()

MOCK_CLI =
  close: ->
  on: ->
  pause: ->
  resume: ->
  prompt: ->
  setPrompt: ->
  removeListener: ->

global.withWatchSpies = (block) ->
  describe '', ->
    beforeEach ->
      addPromiseMatchers this
      addWatchesMatcher this
      spyOn(fs, 'watch').andCallFake -> close: ->
      spyOn(process, 'on').andCallFake ->
      spyOn(process.stdin, 'on').andCallFake ->
      spyOn(process.stdin, 'removeListener').andCallFake ->
      spyOn(process.stdout, 'on').andCallFake ->
      spyOn(process.stdout, 'removeListener').andCallFake ->
      spyOn(process, 'removeListener').andCallFake ->
      spyOn(growly, 'notify').andCallFake (m,o,c) -> c?()
      spyOn(notifySend, 'notify').andCallFake (m,c) -> c?()
      spyOn(rl,'createInterface').andCallFake -> MOCK_CLI
      spyOn(MOCK_CLI, 'on').andCallFake ->
      spyOn(MOCK_CLI, 'close').andCallFake ->
      spyOn(MOCK_CLI, 'pause').andCallFake ->
      spyOn(MOCK_CLI, 'resume').andCallFake ->
      spyOn(MOCK_CLI, 'prompt').andCallFake ->
      spyOn(MOCK_CLI, 'setPrompt').andCallFake ->
      spyOn(MOCK_CLI, 'removeListener').andCallFake ->
      spyOn(fs, 'readFile').andCallFake (path, callback) ->
        switch path
          when Neat.resolve 'Watchfile'
            callback null, '''
              watcher 'mockPlugin', option: 'irrelevant', ->
                watch 'src/(.*)\\\\.coffee$',
                      anotherOption: 'irrelevant',
                      (p,m,g) -> "lib/#{g}.js"

              watcher 'inexistent', ->
            '''
          when Neat.resolve '.watchignore'
            callback null, '''
              \.git
              \.pages
              .*\.tmp
              .DS_Store
              lib
              packages
              node_modules
            '''
      spyOn(Neat, 'require').andCallFake (path) ->
        mockPlugin: MockPlugin

    block.call this

global.cliRunningPlugin = (klass) ->
  setupTest = (klass, changedPath, block) ->
    describe "plugin", ->
      given 'changedPath', -> Neat.resolve changedPath

      beforeEach ->
        @plugin.watch new Watch /src\/.*\.coffee$/

        spyOn(commands, 'run').andCallFake (c, a, options, callback) =>
          if typeof options is 'function'
            [options, callback] = [callback, options]
          setTimeout callback, 1000, 0
          kill: (signal) => @signal = signal

      block.call this


  changedPath = 'src/neat.coffee'
  should =
    withChangedPath: (path) ->
      changedPath = path
      this
    should:
      run: (command, cargs...) ->
        setupTest klass, changedPath, ->
          subject 'promise', ->
            promise = @plugin.pathChanged(@changedPath, 'change')
            promise = promise() if typeof promise is 'function'
            promise

          waiting -> @promise

          promise().should.beFulfilled()

          it "should run #{command} #{cargs.join ' '}", ->
            expect(commands.run).toHaveBeenCalled()
            expect(commands.run.argsForCall[0]).toContain(command)
            expect(commands.run.argsForCall[0]).toContain(cargs)

        should

      runAllWith: (command, cargs...) ->
        setupTest klass, changedPath, ->
          describe 'when calling runAll', ->
            subject 'promise', -> @plugin.runAll()

            waiting -> @promise

            promise().should.beFulfilled()

            it "should run #{command} #{cargs.join ' '}", ->
              expect(commands.run).toHaveBeenCalled()
              expect(commands.run.argsForCall[0]).toContain(command)
              expect(commands.run.argsForCall[0]).toContain(cargs)

        should

      bePendingUntilEnd: ->
        setupTest klass, changedPath, ->
          subject 'promise', ->
            promise = @plugin.pathChanged(@changedPath, 'change')
            promise = promise() if typeof promise is 'function'
            promise

          it 'should be pending until the command end', ->
            ended = false
            runs ->
              waits this, 1000, (=> @plugin.process?), =>
                expect(@plugin.isPending()).toBeTruthy()

              @promise.then (res) =>
                ended = true
                expect(@plugin.isPending()).toBeFalsy()


            waitsFor progress(-> ended), 'Timed out during promise', 2000

        should

      storeProcessAndKillIt: ->
        setupTest klass, changedPath, ->
          describe 'when the plugin was triggered by a change', ->
            subject 'promise', ->
              promise = @plugin.pathChanged(@changedPath, 'change')
              promise = promise() if typeof promise is 'function'
              promise

            it 'should have stored the child process object', ->
              ended = false
              runs ->
                @promise.then ->
                  ended = true
                  expect(@plugin.process).toBeDefined()

              waitsFor progress(-> ended), 'Timed out during promise', 2000

            it 'should have stored the deferred promise object', ->
              ended = false
              runs ->
                @promise.then ->
                  ended = true
                  expect(@plugin.deferred).toBeDefined()

              waitsFor progress(-> ended), 'Timed out during promise', 2000

            describe '::kill method', ->
              it 'should kill the child process', ->
                ended = false
                runs ->
                  waits this, 1000, (=> @plugin.process?), =>
                    @plugin.kill('SIGINT')

                  @promise.then (res) =>
                    ended = true
                    expect(@signal).toBe('SIGINT')
                    expect(res).toBe(1)


                waitsFor progress(-> ended), 'Timed out during promise', 2000

        should

  should



