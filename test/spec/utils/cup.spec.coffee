{resolve} = require "path"

cup = require "../../../lib/utils/cup"

describe 'read', ->
  describe 'when called with a valid cup content', ->
    it 'should return a valid result', (done)->
      content = """prop: "value"
                   otherProp: 10
                   method: (a)-> a * 10"""

      result = cup.read content

      expect(result).toBeDefined()
      expect(result.prop).toBe("value")
      expect(result.otherProp).toBe(10)
      expect(result.method(5)).toBe(50)
      done()

  describe '''when called with a cup content that don\'t compile''', ->
    it 'should return null', (done)->
      content = """prop: "value"
                   otherProp:
                   method: (a)-> a * 10"""

      result = cup.read content

      expect(result).toBe(null)
      done()

  describe '''when called with a cup content that compile
              but that don't eval''', ->
    it 'should return null', (done)->
      content = """prop: "value"
                   otherProp: Foo
                   method: (a)-> a * 10"""

      result = cup.read content

      expect(result).toBe(null)
      done()
