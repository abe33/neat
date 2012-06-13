{resolve} = require "path"
cmd = require "../../../lib/utils/commands"

describe 'decorate', ->
  it 'should create a new property on the target', ->
    target = {}

    cmd.decorate target, "foo", "bar"

    expect(target.foo).toBe("bar")
