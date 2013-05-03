require '../../../../test_helper'

Neat = require '../../../../../lib/neat'
initializer = Neat.require 'config/initializers/templates/stylus'

stylus = require 'stylus'

describe 'stylus initializer', ->
  given 'stylusPath', -> Neat.resolve 'node_modules/stylus/index.js'
  given 'config', -> engines: { templates: {} }

  beforeEach ->
    @stylusRenderCalled = false
    safeStylus = require.cache[@stylusPath].exports
    require.cache[@stylusPath].exports = =>
      render: (tpl) =>
        @stylusRenderCalled = true

  it 'should exist', ->
    expect(initializer).toBeDefined()

  describe 'when called', ->
    beforeEach ->
      initializer @config

    it 'should have added the stylus template engine to the config', ->
      expect(@config.engines.templates.stylus).toBeDefined()
      expect(@config.engines.templates.stylus.render).toBeDefined()

    describe 'the defined render method', ->
      subject 'render', ->
        @config.engines.templates.stylus.render

      describe 'when called', ->
        it 'should have called the stylus render method', ->
          @render 'foo'
          expect(@stylusRenderCalled).toBeTruthy()


