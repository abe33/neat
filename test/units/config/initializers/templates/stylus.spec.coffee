require '../../../../test_helper'

Neat = require '../../../../../lib/neat'
initializer = Neat.require 'config/initializers/templates/stylus'

stylus = require 'stylus'
{logger} = Neat.require 'utils/logs'

describe 'stylus initializer', ->
  given 'stylusPath', -> Neat.resolve 'node_modules/stylus/index.js'
  given 'config', -> engines: { templates: {} }

  beforeEach ->
    @stylusRenderCalled = false
    @safeStylus = require.cache[@stylusPath].exports
    require.cache[@stylusPath].exports = (tpl) =>
      render: (cb) =>
        @stylusRenderCalled = true
        cb? null, 'irrelevant'

  afterEach -> require.cache[@stylusPath].exports = @safeStylus

  it 'should exist', ->
    expect(initializer).toBeDefined()

  describe 'when called', ->
    beforeEach -> initializer @config

    it 'should have added the stylus template engine to the config', ->
      expect(@config.engines.templates.stylus).toBeDefined()
      expect(@config.engines.templates.stylus.render).toBeDefined()

    describe 'the defined render method', ->
      subject 'render', -> @config.engines.templates.stylus.render

      describe 'when called', ->
        it 'should have called the stylus render method', ->
          result = @render 'foo'
          expect(@stylusRenderCalled).toBeTruthy()
          expect(result).toBe('irrelevant')

  describe 'when the stylus render fails', ->
    beforeEach ->
      @stylusRenderCalled = false
      @safeStylus = require.cache[@stylusPath].exports
      require.cache[@stylusPath].exports = (tpl) =>
        render: (cb) => cb? new Error('irrelevant')

      initializer @config

    subject 'render', -> @config.engines.templates.stylus.render

    afterEach -> require.cache[@stylusPath].exports = @safeStylus

    it 'should have raised an error', ->
      expect(-> @render 'foo').toThrow()

  describe 'when the module is not installed', ->
    beforeEach ->
      spyOn(require('module'), '_load').andCallFake ->
        throw new Error 'irrelevant'
      spyOn(logger, 'log').andCallFake ->

      initializer @config

    subject 'render', -> @config.engines.templates.stylus.render

    it 'should log an error', ->
      @render 'foo'
      expect(logger.log).toHaveBeenCalled()

