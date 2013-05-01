require '../../test_helper'

javascript = require '../../../lib/processing/javascript.build'

describe 'javascript processing promise', ->
  given 'buffer', ->
    {
      '/foo/file.js': 'var bar;'
      '/baz/file.js': 'var baz;'
    }

  describe 'uglify', ->

    it 'should exists', ->
      expect(javascript.uglify).toBeDefined()

    describe 'called without a valid file buffer', ->
      it 'should raise an exception', ->
        expect(=> javascript.uglify 5).toThrow()
        expect(=> javascript.uglify 'foo').toThrow()
        expect(=> javascript.uglify null).toThrow()

    subject 'promise', -> javascript.uglify @buffer

    promise()
    .should.beFulfilled()
    .should 'returns a minified buffer', (buffer) ->
      expect(buffer['/foo/file.min.js']).toBeDefined()
      expect(buffer['/baz/file.min.js']).toBeDefined()


