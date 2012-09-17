require '../../test_helper'

Neat = require '../../../lib/neat'
Loader = require '../../../lib/i18n/loader'

describe 'I18n::Loader', ->
  describe 'when loading files in the given path', ->
    beforeEach ->
      paths = ["#{Neat.root}/test/fixtures/i18n"]
      @loader = new Loader paths
      ended = false
      runs ->
        @loader.load (err) ->
          expect(err).toBeUndefined()
          ended = true

      waitsFor progress(-> ended), 'Timed out', 1000

    it 'should have detected all the languages present', ->
      expect(@loader.languages).toEqual(['de','en','fr'])

    it 'should contains what the files defines', ->
      expect(@loader.locales.en.neat.test).toBe('foo')
      expect(@loader.locales.fr.neat.test).toBe('bar')
      expect(@loader.locales.de.neat.other_test).toBe('baz de')
