require '../../test_helper'
{resolve} = require "path"

ex = require "../../../lib/utils/exports"

describe 'namespace', ->
  it "should decorate the object's properties with
      the specified namespace".squeeze(), ->

    target = ex.namespace 'foo', a:'a', b:'b', c:'c'

    expect(target['foo:a']).toBe('a')
    expect(target['foo:b']).toBe('b')
    expect(target['foo:c']).toBe('c')

  it 'should set a property whose name is namespace when
      an index is provided in the source object'.squeeze(), ->

    target = ex.namespace 'foo', a:'a', index:'index'

    expect(target['foo']).toBe('index')
    expect(target['foo:a']).toBe('a')

describe 'combine', ->

  it 'should returns an object whose content is the aggregated exports
      of the files that matches the passed-in patterns'.squeeze(), ->

    object = ex.combine /_[a-z]+$/,
                        [resolve '.', 'test/fixtures/utils/exports']

    expect(object.A).toBe('A')
    expect(object.B).toBe('B')
    expect(object.C).toBe('C')
