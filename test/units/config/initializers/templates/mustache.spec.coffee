require '../../../../test_helper'

Neat = require '../../../../../lib/neat'
initializer = Neat.require 'config/initializers/templates/mustache'

mustache = require 'mustache'

describe 'mustache initializer', ->
  given 'config', -> engines: { templates: {} }

  beforeEach ->
    spyOn(mustache, 'to_html').andCallFake ->

  it 'should exist', ->
    expect(initializer).toBeDefined()

  describe 'when called', ->
    beforeEach ->
      initializer @config

    it 'should have added the mustache template engine to the config', ->
      expect(@config.engines.templates.mustache).toBeDefined()
      expect(@config.engines.templates.mustache.render).toBeDefined()

    describe 'the defined render method', ->
      subject 'render', ->
        @config.engines.templates.mustache.render

      describe 'when called', ->
        it 'should have called the mustache render method', ->
          @render 'foo'
          expect(mustache.to_html).toHaveBeenCalled()

