cp = require 'child_process'
require '../../test_helper'
{resolve} = require "path"
cmd = require "../../../lib/utils/commands"

global.task = ->

describe 'decorate', ->
  it 'should create a new property on the target', ->
    target = {}

    cmd.decorate target, "foo", "bar"

    expect(target.foo).toBe("bar")

describe 'aliases', ->
  it 'should decorate the target with an aliases property', ->
    target = {}

    cmd.aliases 'foo', 'bar', target
    expect(target.aliases).toEqual(['foo', 'bar'])

describe 'deprecated', ->
  it 'should decorate the target with an deprecated property', ->
    target = {}

    cmd.deprecated 'irrelevant', target
    expect(target.deprecated).toEqual('irrelevant')

describe 'environment', ->
  it 'should decorate the target with an environment property', ->
    target = {}

    cmd.environment 'irrelevant', target
    expect(target.environment).toEqual('irrelevant')

describe 'help', ->
  it 'should decorate the target with an help property', ->
    target = {}

    cmd.help 'irrelevant', target
    expect(target.help).toEqual('irrelevant')

describe 'usages', ->
  it 'should decorate the target with an usages property', ->
    target = {}

    cmd.usages 'foo', 'bar', target
    expect(target.usages).toEqual(['foo', 'bar'])

describe 'neatTask', ->
  given 'parameters', ->
    {
      name: 'name'
      description: 'description'
      environment: 'environment'
      action: (callback) ->
    }

  beforeEach ->
    spyOn(global, 'task')

  it 'should register a task with the task method', ->
    cmd.neatTask @parameters

    expect(task).toHaveBeenCalled()

describe 'neatTaskAlias', ->
  beforeEach ->
    spyOn(global, 'task')

  it 'should register a task with the task method', ->
    cmd.neatTaskAlias 'compile', 'compileAlias', 'environment'

    expect(task).toHaveBeenCalled()

describe 'run', ->
  beforeEach ->
    spyOn(cp, 'spawn').andCallFake (command, params) ->
      stdout:
        on: (event, callback) ->
      stderr:
        on: (event, callback) ->
      on: (event, callback) ->
        callback?(0) if event is 'exit'

  it 'should have spawned a child process', (done) ->
    cmd.run 'foo', ['bar'], (status) ->
      expect(cp.spawn).toHaveBeenCalled()
      done()

describe 'asyncErrorTrap', ->
  describe 'used on an async method without custom callback', ->
    describe 'when the async function fails', ->
      it 'should never call anything', ->
        asyncFunc = (callback) ->
          callback {}

        callbackCalled = false
        asyncFunc cmd.asyncErrorTrap (res) ->
          callbackCalled = true

        expect(callbackCalled).toBeFalsy()

    describe 'when the async function succeed', ->
      it 'should never call anything', ->
        asyncFunc = (callback) ->
          callback null, {}

        callbackCalled = false
        asyncFunc cmd.asyncErrorTrap (res) ->
          callbackCalled = true

        expect(callbackCalled).toBeTruthy()

  describe 'used on an async method with custom callback', ->
    describe 'when the async function fails', ->
      it 'should never call anything', ->
        asyncFunc = (callback) ->
          callback {}

        callbackCalled = false
        customCallbackCalled = false

        customCallback = -> customCallbackCalled = true

        asyncFunc cmd.asyncErrorTrap customCallback, (res) ->
          callbackCalled = true

        expect(callbackCalled).toBeFalsy()
        expect(customCallbackCalled).toBeTruthy()

    describe 'when the async function succeed', ->
      it 'should never call anything', ->
        asyncFunc = (callback) ->
          callback null, {}

        callbackCalled = false
        customCallbackCalled = false

        customCallback = -> customCallbackCalled = true

        asyncFunc cmd.asyncErrorTrap customCallback, (res) ->
          callbackCalled = true

        expect(callbackCalled).toBeTruthy()
        expect(customCallbackCalled).toBeFalsy()

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
