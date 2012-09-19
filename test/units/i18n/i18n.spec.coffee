require '../../test_helper'

Neat = require '../../../lib/neat'
I18n = require '../../../lib/i18n/i18n'

describe 'I18n', ->
  describe 'with files loaded from the given paths', ->
    beforeEach ->
      paths = ["#{Neat.root}/test/fixtures/i18n"]
      @i18n = new I18n paths
      @i18n.load()

    it 'should have detected all the languages present', ->
      expect(@i18n.languages).toEqual(['de','en','fr'])

    it 'should contains what the files defines', ->
      expect(@i18n.locales.en.neat.test).toBe('foo')
      expect(@i18n.locales.fr.neat.test).toBe('bar')
      expect(@i18n.locales.de.neat.other_test).toBe('baz de')

    describe 'calling get', ->
      describe 'with a language and a path', ->
        it 'should return the corresponding string', ->
          expect(@i18n.get 'en', 'neat.test').toBe('foo')
          expect(@i18n.get 'fr', 'neat.test').toBe('bar')
          expect(@i18n.get 'de', 'neat.other_test').toBe('baz de')

      describe 'without a language', ->
        it 'should default to english', ->
          expect(@i18n.get 'neat.test').toBe('foo')
          expect(@i18n.get 'neat.other_test').toBe('baz en')

      describe 'with a path that don\'t exist', ->
        it 'should return the last element in the path', ->
          expect(@i18n.get 'neat.foo_bar_baz').toBe('Foo Bar Baz')
          expect(@i18n.get 'neat.foo-bar-baz').toBe('Foo Bar Baz')
          expect(@i18n.get 'neat.foo.bar-baz').toBe('Bar Baz')

      describe 'with an inexistant language it', ->
        it 'should throw an error', ->
          expect(-> @i18n.get 'it', 'neat.test').toThrow()

    describe 'calling getHelper', ->
      it 'should return a function bind to the I18n::get method', ->
        _ = @i18n.getHelper()

        expect(_('neat.test')).toBe('foo')
        expect(_('neat.other_test')).toBe('baz en')
