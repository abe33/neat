require '../../test_helper'

processing = require '../../../lib/processing'

describe 'processing index', ->
  describe '#core', ->
    it 'should exist', ->
      expect(processing.core).toBeDefined()

  describe '#coffee', ->
    it 'should exist', ->
      expect(processing.coffee).toBeDefined()


