fs = require 'fs'
path = require 'path'

eS = fs.existsSync or path.existsSync

global.addFileMatchers = (scope) ->
  scope.addMatchers
    toExist: () ->
      actual = @actual
      notText = if @isNot then " not" else ""

      @message = ->
        "Expected #{actual}#{notText} to exist"

      eS @actual

    toContain: (matcher) ->
      actual = @actual
      notText = if @isNot then " not" else ""
      @message = ->
        """Expected content:
           "#{@content}"
           of file #{actual}#{notText} to contains :
           "#{matcher?.description or matcher}" """

      return false unless eS @actual

      @content = fs.readFileSync(@actual).toString()
      if typeof matcher is 'function'
        matcher.call scope, @content
      else
        @expected = matcher
        @content.indexOf(@expected) >= 0
