
global.addPromiseMatchers = (scope) ->
  scope.addMatchers
    toBePromise: ->
      notText = if @isNot then " not" else ""
      @message = ->
        "Expected #{@actual}#{notText} to be a promise"

      @actual? and @actual.then?


global.promise = (promise) ->
  should = (msg, block) ->
    it "the returned promise should #{msg}", ->
      ended = false
      runs ->
        promise.call(this)
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
        promise.call(this)
        .then ->
          expect(true).toBeTruthy()
          ended = true
        .fail ->
          expect(false).toBeTruthy()
          ended = true

      waitsFor progress(-> ended), "Timed out in beFulfilled", 1000
    this

  should.beRejected = ->
    it 'the returned promise should be rejected', ->
      ended = false
      runs ->
        promise.call(this)
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
        promise.call(this)
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
        promise.call(this)
        .then (result) ->
          expect(result).toEqual(expectedResult)
          ended = true
        .fail ->
          expect(null).toEqual(expectedResult)
          ended = true

      waitsFor progress(-> ended), "Timed out in returns", 1000
    this

  should.should = should
  {should}
