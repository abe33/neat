require '../../../../test_helper'

Neat = require '../../../../../lib/neat'
initializer = Neat.require 'config/initializers/templates/haml_coffee'

haml_coffee = require 'haml-coffee'

describe 'haml_coffee initializer', ->
  given 'hamlcPath', -> Neat.resolve 'node_modules/haml-coffee/index.js'
  given 'config', -> engines: { templates: {} }

  beforeEach ->
    @hamlcRenderCalled = false
    @safeHamlc = require.cache[@hamlcPath].exports
    require.cache[@hamlcPath].exports = compile: => =>
      @hamlcRenderCalled = true
      'irrelevant'

  afterEach -> require.cache[@hamlcPath].exports = @safeHamlc

  it 'should exist', ->
    expect(initializer).toBeDefined()

  describe 'when called', ->
    beforeEach -> initializer @config

    it 'should have added the haml_coffee template engine to the config', ->
      expect(@config.engines.templates.hamlc).toBeDefined()
      expect(@config.engines.templates.hamlc.render).toBeDefined()

    describe 'the defined render method', ->
      subject 'render', -> @config.engines.templates.hamlc.render

      describe 'when called', ->
        it 'should have called the haml_coffee render method', ->
          result = @render 'foo'
          expect(@hamlcRenderCalled).toBeTruthy()
          expect(result).toBe('irrelevant')

  describe 'when the module isnt installed', ->
    beforeEach ->
      spyOn(require('module'), '_load').andCallFake ->
        throw new Error 'irrelevant'

      initializer @config

    subject 'render', -> @config.engines.templates.hamlc.render

    it 'should throw an exception', ->
      expect(-> @render 'foo').toThrow()

