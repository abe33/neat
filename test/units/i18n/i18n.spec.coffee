require '../../test_helper'

Neat = require '../../../lib/neat'
I18n = require '../../../lib/i18n/i18n'

describe 'I18n', ->
  describe 'with files loaded from the given paths', ->
    beforeEach ->
      paths = ["#{Neat.root}/test/fixtures/i18n"]
      @i18n = new I18n paths
      ended = false
      @i18n.load()

    it 'should have detected all the languages present', ->
      expect(@i18n.languages).toEqual(['de','en','fr'])

    it 'should contains what the files defines', ->
      expect(@i18n.locales.en.neat.test).toBe('foo')
      expect(@i18n.locales.fr.neat.test).toBe('bar')
      expect(@i18n.locales.de.neat.other_test).toBe('baz de')

    describe 'calling get with a language and a path', ->
      it 'should return the corresponding string', ->
        expect(@i18n.get 'en', 'neat.test').toBe('foo')
        expect(@i18n.get 'fr', 'neat.test').toBe('bar')
        expect(@i18n.get 'de', 'neat.other_test').toBe('baz de')

    describe 'calling get without a language', ->
      it 'should default to english', ->
        expect(@i18n.get 'neat.test').toBe('foo')
        expect(@i18n.get 'neat.other_test').toBe('baz en')
