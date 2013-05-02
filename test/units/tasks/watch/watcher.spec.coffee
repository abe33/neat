require '../../../test_helper'

fs = require 'fs'
rl = require 'readline'
path = require 'path'
Q = require 'q'
Neat = require '../../../../lib/neat'

Watcher = require '../../../../lib/tasks/watch/watcher'

describe 'Watcher', ->
  withWatchSpies ->
    afterEach -> @watcher.dispose()

    subject 'watcher', -> new Watcher

    it 'should exist', ->
      expect(@watcher).toBeDefined()

    describe '::dispose', ->
      subject 'promise', -> @watcher.init().then @watcher.dispose

      waiting -> @promise

      it 'should return a promise', ->
        expect(@promise).toBePromise()

      promise().should.beFulfilled()

      it 'should unregister the listener on SIGINT', ->
        expect(process.removeListener)
        .toHaveBeenCalledWith('SIGINT', @watcher.sigintListener)

      it 'should unregister the listener on stdin keypress', ->
        expect(process.stdin.removeListener)
        .toHaveBeenCalledWith('keypress', @watcher.keypressListener)

      it 'should unregister the listener on the cli', ->
        expect(@watcher.cli.removeListener).toHaveBeenCalled()

      it 'should have closed the cli', ->
        expect(@watcher.cli.close).toHaveBeenCalled()

    describe '#init', ->

      given 'value', -> @promise.valueOf()
      given 'paths', -> fs.watch.argsForCall.map (a) -> a[0]

      subject 'promise', -> @watcher.init()
      waiting -> @promise

      it 'should return a promise', ->
        expect(@promise).toBePromise()

      it 'should register an event on SIGINT', ->
        expect(process.on)
        .toHaveBeenCalledWith('SIGINT', @watcher.sigintListener)

      it 'should register an event on stdin keypress', ->
        expect(process.stdin.on)
        .toHaveBeenCalledWith('keypress', @watcher.keypressListener)

      it 'should have created a cli and opened a prompt', ->
        expect(rl.createInterface).toHaveBeenCalled()
        expect(@watcher.cli.setPrompt).toHaveBeenCalled()
        expect(@watcher.cli.prompt).toHaveBeenCalled()
        expect(@watcher.cli.on).toHaveBeenCalled()

      promise().should.beFulfilled()

      it 'should returns a list of ignored path', ->
        ['.git', 'node_modules', 'lib'].forEach (p) =>
          expect(@value.ignoredPaths).toContain(Neat.resolve p)

      it 'should returns a list of watched path', ->
        [
          '.neat'
          'Cakefile'
          'Nemfile'
          'Watchfile'
          '.watchignore'
        ].forEach (p) =>
          expect(@value.watchedPaths).toContain(Neat.resolve p)

      it 'should have stored the promise as a queue bootstrap', ->
        expect(@watcher.promise).toBe(@promise)

      it 'should have registered watchers for all the watched paths', ->
        for path in @value.watchedPaths
          expect(@paths).toContain(path)

      it 'should not have registered doublons', ->
        uniqPaths = @paths.uniq()
        expect(@paths.length).toBe(uniqPaths.length)

      it 'should have evaluated the Watchfile and initialized the plugins', ->
        expect(@watcher.plugins.mockPlugin).toBeDefined()
        expect(@watcher.plugins.mockPlugin.watcher).toBe(@watcher)

      describe 'once called,', ->
        given 'plugin', -> @watcher.plugins.mockPlugin
        given 'watches', -> @plugin.watches
        given 'watch', -> @watches.first()
        given 'watchOptions', -> @watch.options
        given 'pluginOptions', -> @plugin.options

        describe 'the watcher cli', ->
          describe 'when a ctrl + l is pressed', ->
            beforeEach ->
              spyOn(process.stdout, 'write').andCallFake ->
              @watcher.keypressListener 'l', name: 'l', ctrl: true

            it 'should have cleared the terminal', ->
              expect(process.stdout.write)
              .toHaveBeenCalledWith('\u001B[2J\u001B[0;0f')

          describe 'when a sigint is triggered', ->
            beforeEach ->
              spyOn(process, 'exit').andCallFake(->)
              spyOn(@plugin, 'kill').andCallFake(->)

            describe 'during a plugin run', ->
              it 'should kill the plugin running', (done) ->
                triggerChangesFor Neat.resolve('src/neat.coffee')
                setTimeout =>
                  @watcher.sigintListener()
                  expect(@plugin.kill).toHaveBeenCalled()
                  done()
                , 5

            describe 'between plugin runs', ->
              it 'should kill the process', ->
                @watcher.sigintListener()
                expect(process.exit).toHaveBeenCalled()

          describe 'while waiting for input', ->
            beforeEach ->
              spyOn(process, 'exit').andCallFake(->)
              spyOn(@watcher, 'runAll').andCallThrough()
              spyOn(@watcher, 'displayHelp').andCallFake(->)

            ['', 'a', 'all'].forEach (val) ->
              describe "when '#{val}' is submitted", ->
                beforeEach ->
                  @watcher.lineListener val

                it 'should call runAll', ->
                  expect(@watcher.runAll).toHaveBeenCalled()

            ['h', 'help'].forEach (val) ->
              describe "when '#{val}' is submitted", ->
                beforeEach ->
                  @watcher.lineListener val

                it 'should call displayHelp', ->
                  expect(@watcher.displayHelp).toHaveBeenCalled()

            ['e', 'q', 'exit', 'quit'].forEach (val) ->
              describe "when '#{val}' is submitted", ->
                beforeEach ->
                  @watcher.lineListener val

                it 'should call ', ->
                  expect(process.exit).toHaveBeenCalled()

            describe "when 'foo' is submitted", ->
              beforeEach ->
                spyOn(process.stdout, 'write').andCallFake ->
                @watcher.lineListener 'foo'

              it 'should have printed an error', ->
                expect(process.stdout.write).toHaveBeenCalled()


        describe 'the instanciated plugin', ->
          subject -> @plugin

          it 'should have been initialized
              with the watches defined in the Watchfile'.squeeze(), ->
            expect(@watches)
            .toContainWatchFor(///#{Neat.root}/src/(.*)\.coffee$///)

          it 'should have registered the given options', ->
            expect(@pluginOptions.option).toBeDefined()
            expect(@watchOptions.anotherOption).toBeDefined()

          describe 'when a watch contains a block', ->
            given 'promise', ->
              @watch.outputPathsFor Neat.resolve 'src/neat.coffee'

            waiting -> @promise

            promise()
            .should.beFulfilled()
            .should 'have registered the given block', (paths) ->
              expect(paths).toContain(Neat.resolve 'lib/neat.js')

          it 'should confirm if it is concerned by changes in a given path', ->
            expect(@plugin.match Neat.resolve 'src/neat.coffee').toBeTruthy()
            expect(@plugin.match Neat.resolve 'foo').toBeFalsy()

          describe 'when a file concerned by the plugin changed', ->
            beforeEach -> spyOn(@plugin, 'pathChanged').andCallThrough()

            subject 'promise', ->
              triggerChangesFor Neat.resolve('src/neat.coffee')
              @watcher.promise

            waiting -> @promise

            promise().should.beFulfilled()

            it 'should have called the plugin pathChanged method', ->
              expect(@plugin.pathChanged).toHaveBeenCalled()

            it 'should have stored the promise in the promises queue', ->
              expect(@watcher.promise).toBe(@promise)


        ['Watchfile', '.watchignore'].forEach (name) =>
          describe "when #{name} file changed", ->
            beforeEach ->
              spyOn(@watcher, 'init').andCallThrough()
              spyOn(@watcher, 'dispose').andCallThrough()
              spyOn(@plugin, 'dispose').andCallThrough()

            subject 'promise', ->
              triggerChangesFor Neat.resolve(name)
              @watcher.promise

            waiting -> @promise

            promise()
            .should.beFulfilled()
            .should 'dispose itself and its plugins', ->
              expect(@watcher.dispose).toHaveBeenCalled()
              expect(@plugin.dispose).toHaveBeenCalled()
            .should 'reinitialize the watcher by calling init again', ->
              expect(@watcher.init).toHaveBeenCalled()

            it 'should have stored a promise as a queue bootstrap', ->
              expect(@watcher.promise).toBe(@promise)





