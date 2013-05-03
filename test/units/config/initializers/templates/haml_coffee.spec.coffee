require '../../../../test_helper'

Neat = require '../../../../../lib/neat'
initializer = Neat.require 'config/initializers/templates/haml_coffee'

haml_coffee = require 'haml-coffee'

describe 'haml_coffee initializer', ->
  given 'hamlcPath', -> Neat.resolve 'node_modules/haml-coffee/index.js'
  given 'config', -> engines: { templates: {} }

  beforeEach ->
    @haml_coffeeRenderCalled = false
    safehaml_coffee = require.cache[@hamlcPath].exports
    require.cache[@hamlcPath].exports = compile: => =>
      @haml_coffeeRenderCalled = true

  it 'should exist', ->
    expect(initializer).toBeDefined()

  describe 'when called', ->
    beforeEach ->
      initializer @config

    it 'should have added the haml_coffee template engine to the config', ->
      expect(@config.engines.templates.hamlc).toBeDefined()
      expect(@config.engines.templates.hamlc.render).toBeDefined()

    describe 'the defined render method', ->
      subject 'render', ->
        @config.engines.templates.hamlc.render

      describe 'when called', ->
        it 'should have called the haml_coffee render method', ->
          @render 'foo'
          expect(@haml_coffeeRenderCalled).toBeTruthy()


