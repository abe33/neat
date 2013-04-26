
global.addPromiseMatchers = (scope) ->
  scope.addMatchers
    toBePromise: ->
      notText = if @isNot then " not" else ""
      @message = ->
        "Expected #{@actual}#{notText} to be a promise"

      @actual? and @actual.then?

    toBeSamePromise: (promise) ->
      notText = if @isNot then " not" else ""
      @message = ->
        "Expected #{@actual}#{notText} to be #{promise}"

      @actual is promise


global.promise = (promise) ->
  should = (msg, block) ->
    it "the returned promise should #{msg}", ->
      ended = false
      runs ->
        (promise?.call(this) or @promise or @subject)
        .then =>
          block.apply(this, arguments)
          ended = true
        .fail =>
          block.apply(this, arguments)
          ended = true

      waitsFor progress(-> ended), "Timed out in should", 1000
    this

  should.beFulfilled = ->
    it 'the returned promise should be fulfilled', ->
      ended = false
      runs ->
        (promise?.call(this) or @promise or @subject)
        .then ->
          expect(true).toBeTruthy()
          ended = true
        .fail (err) ->
          expect(false).toBeTruthy()
          ended = true

      waitsFor progress(-> ended), "Timed out in beFulfilled", 1000
    this

  should.beRejected = ->
    it 'the returned promise should be rejected', ->
      ended = false
      runs ->
        (promise?.call(this) or @promise or @subject)
        .then ->
          expect(false).toBeTruthy()
          ended = true
        .fail ->
          expect(true).toBeTruthy()
          ended = true

      waitsFor progress(-> ended), "Timed out in beRejected", 1000
    this

  should.failWith = (msg, block) ->
    it "the returned promise should fail with #{msg}", ->
      ended = false
      runs ->
        (promise?.call(this) or @promise or @subject)
        .then =>
          block.apply(this, arguments)
          ended = true
        .fail =>
          block.apply(this, arguments)
          ended = true

      waitsFor progress(-> ended), "Timed out in failWith", 1000
    this

  should.returns = (msg, block) ->
    it "the returned promise should return #{msg}", ->
      ended = false
      expectedResult = block.call this
      runs ->
        (promise?.call(this) or @promise or @subject)
        .then (result) ->
          expect(result).toEqual(expectedResult)
          ended = true
        .fail (err) ->
          expect(err).toEqual(expectedResult)
          ended = true

      waitsFor progress(-> ended), "Timed out in returns", 1000
    this

  should.should = should
  {should}
