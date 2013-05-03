require '../../test_helper'
{resolve} = require "path"
l = require "../../../lib/utils/logs"

describe 'prefix', ->
  it 'should prepend the given prefix to the string', ->
    str = "foo"
    str = l.prefix str, "bar"

    expect(str).toBe("bar foo")

['blue', 'cyan', 'red', 'yellow', 'magenta', 'green'].forEach (color) ->
  describe "#{color}", ->
    it 'should returned a colorized vresion of the passed-in string', ->
      expect(l[color] 'foo').toBe('foo'[color])

describe 'puts', ->
  beforeEach ->
    spyOn(l.logger, 'log').andCallFake ->

  it 'should log the passed-in message', ->
    l.puts 'irrelevant'

    expect(l.logger.log).toHaveBeenCalledWith('irrelevant\n', 0)

  it 'should log the passed-in message and log level', ->
    l.puts 'irrelevant', 5

    expect(l.logger.log).toHaveBeenCalledWith('irrelevant\n', 5)

describe 'print', ->
  beforeEach ->
    spyOn(l.logger, 'log').andCallFake ->

  it 'should log the passed-in message', ->
    l.print 'irrelevant'

    expect(l.logger.log).toHaveBeenCalledWith('irrelevant', 0)

  it 'should log the passed-in message and log level', ->
    l.print 'irrelevant', 5

    expect(l.logger.log).toHaveBeenCalledWith('irrelevant', 5)

{debug: 0, info: 1, warn: 2, error: 3,  fatal: 4}.each (k,v) ->
  describe "#{k}", ->
    beforeEach ->
      spyOn(l.logger, 'log').andCallFake ->

    it 'should have log the passed-in message with the corresponding level', ->
      l[k] 'irrelevant', v

      expect(l.logger.log.argsForCall.first()).toContain(v)
