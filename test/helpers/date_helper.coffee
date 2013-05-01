global.addDateMatchers = (scope) ->
  scope.addMatchers
    toEqualDate: (date) ->
      notText = if @isNot then " not" else ""
      @message = ->
        "Expected #{@actual}#{notText} to be a date equal to #{date}"

      @actual.getYear() is date.getYear() and
      @actual.getMonth() is date.getMonth() and
      @actual.getDate() is date.getDate() and
      @actual.getHours() is date.getHours() and
      @actual.getMinutes() is date.getMinutes() and
      @actual.getSeconds() is date.getSeconds()
