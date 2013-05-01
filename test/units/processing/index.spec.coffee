require '../../test_helper'

processing = require '../../../lib/processing'

describe 'processing index', ->
  describe '#core', ->
    it 'should exist', ->
      expect(processing.join).toBeDefined()
      expect(processing.relocate).toBeDefined()
      expect(processing.fileHeader).toBeDefined()
      expect(processing.fileFooter).toBeDefined()
      expect(processing.remove).toBeDefined()
      expect(processing.readFiles).toBeDefined()
      expect(processing.writeFiles).toBeDefined()

  describe '#coffee', ->
    it 'should exist', ->
      expect(processing.compile).toBeDefined()
      expect(processing.stripRequires).toBeDefined()
      expect(processing.exportsToPackage).toBeDefined()
      expect(processing.annotate).toBeDefined()


