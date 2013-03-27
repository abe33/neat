fs = require 'fs'
Q = require 'q'
Neat = require '../../../../lib/neat'
WatchPlugin = Neat.require 'tasks/watch/watch_plugin'
Watch = Neat.require 'tasks/watch/watch'
commands = Neat.require 'utils/commands'

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

global.withWatchSpies = (block) ->
  describe '', ->
    beforeEach ->
      addPromiseMatchers this
      addWatchesMatcher this
      spyOn(fs, 'watch').andCallFake -> close: ->
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
        mockPlugin: class MockPlugin extends WatchPlugin
          pathChanged: (path) -> Q.fcall ->

    block.call this

global.cliRunningPlugin = (klass) ->
  changedPath = 'src/neat.coffee'
  should =
    withChangedPath: (path) ->
      changedPath = path
      this
    should:
      run: (command, cargs...) ->
        describe '', ->
          given 'changedPath', -> Neat.resolve changedPath

          beforeEach ->
            @plugin.watch new Watch /src\/.*\.coffee$/

            spyOn(commands, 'run').andCallFake (c, a, options, callback) ->
              if typeof options is 'function'
                [options, callback] = [callback, options]
              callback 0

          subject 'promise', ->
            promise = @plugin.pathChanged(@changedPath, 'change')
            promise = promise() if typeof promise is 'function'
            promise

          waiting -> @promise

          promise().should.beFulfilled()

          it "should have ran #{command} #{cargs.join ' '}", ->
            expect(commands.run).toHaveBeenCalled()
            expect(commands.run.argsForCall[0]).toContain(command)
            expect(commands.run.argsForCall[0]).toContain(cargs)

        this

  should



