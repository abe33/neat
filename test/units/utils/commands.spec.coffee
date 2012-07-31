require '../../test_helper'
{resolve} = require "path"
cmd = require "../../../lib/utils/commands"

describe 'decorate', ->
  it 'should create a new property on the target', ->
    target = {}

    cmd.decorate target, "foo", "bar"

    expect(target.foo).toBe("bar")

describe 'hashArguments', ->
  describe 'when called with proper syntax', ->
    it 'should return a corresponding hash', ->

      source = [
        'string:bar',
        'stringWithSpaces:"bar baz",\'foo bar\'',
        'int:10',
        'float:-10.50',
        'array:foo,10,true',
        'falsy:false,no,off',
        'truthy:true,yes,on',
      ]

      expect(cmd.hashArguments source).toEqual
        string: 'bar'
        stringWithSpaces: ['bar baz','foo bar']
        int: 10
        float: -10.50
        array: ['foo', 10, true]
        falsy: [false, false, false]
        truthy: [true, true, true]

  describe 'when called with missing colon', ->
    it 'should set the flag to true', ->
      source = ['foo']
      expect(cmd.hashArguments source).toBeTruthy()

  describe 'when called with colon and empty value', ->
    it 'should raise an exception', ->
      source = ['foo:']
      expect(-> cmd.hashArguments source).toThrow()
