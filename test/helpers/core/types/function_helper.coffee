global.addFunctionMatchers = (scope) ->
  scope.addMatchers
    toBeAsync: () ->
      actual = @actual
      notText = if @isNot then " not" else ""

      @message = ->
        "Expected #{actual}#{notText} to be asynchronous"

      @actual.isAsync()
