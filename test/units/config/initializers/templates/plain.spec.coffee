require '../../../../test_helper'

Neat = require '../../../../../lib/neat'
initializer = Neat.require 'config/initializers/templates/plain'

describe 'plain initializer', ->
  given 'config', -> engines: { templates: {} }

  it 'should exist', ->
    expect(initializer).toBeDefined()

  describe 'when called', ->
    beforeEach ->
      initializer @config

    it 'should have added the plain template engine to the config', ->
      expect(@config.engines.templates.plain).toBeDefined()
      expect(@config.engines.templates.plain.render).toBeDefined()

    describe 'the render method', ->
      subject 'render', -> @config.engines.templates.plain.render

      describe 'called with a template content', ->
        given 'template', -> 'irrelevant'

        it 'should return the template unchanged', ->
          expect(@render @template).toBe(@template)

