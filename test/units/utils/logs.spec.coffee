require '../../test_helper'
{resolve} = require "path"
l = require "../../../lib/utils/logs"

describe 'prefix', ->
  it 'should prepend the given prefix to the string', ->
    str = "foo"
    str = l.prefix str, "bar"

    expect(str).toBe("bar foo")
