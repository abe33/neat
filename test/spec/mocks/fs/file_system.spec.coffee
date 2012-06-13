{FileSystem} = require './file_system'

describe 'FileSystem#removeTrailingSlash', ->
  it 'should remove the trailing slash at the end of the path', ->
    fs = new FileSystem
    expect(fs.removeTrailingSlash '/foo/').toBe('/foo')
    expect(fs.removeTrailingSlash '/foo/bar/').toBe('/foo/bar')

  it 'should leave the path unchanged', ->
    fs = new FileSystem
    expect(fs.removeTrailingSlash '/foo').toBe('/foo')
    expect(fs.removeTrailingSlash '/foo/bar').toBe('/foo/bar')

describe 'FileSystem', ->
  describe 'when creating a file system', ->
    it 'should provides a basic root named /', ->
      fs = new FileSystem

      expect(fs.root).toBe('/')
      expect(fs.structure).toEqual({})

    it 'should also allow a directory structure as argument', ->
      fs = new FileSystem
        foo: {}
        bar:
          file: 'foo'

      expect(fs.read '/').toEqual(['bar','foo'])
      expect(fs.exists '/foo').toBeTruthy()
      expect(fs.exists '/foo').toBeTruthy()
      expect(fs.exists '/bar').toBeTruthy()
      expect(fs.exists '/bar/file').toBeTruthy()
      expect(fs.exists '/baz').toBeFalsy()
      expect(fs.read '/bar/file').toBe('foo')

    it 'should allow to create directories and files', ->
      fs = new FileSystem

      fs.mkdir '/foo'
      fs.mkdir '/foo/bar'
      fs.mkdir '/foo/baz'

      expect(fs.read '/').toEqual(['foo'])
      expect(fs.read '/foo').toEqual(['bar','baz'])

      fs.write '/foo/file.ext', 'foo'
      fs.write '/foo/bar/file.ext', 'bar'
      fs.write '/foo/baz/file.ext', 'baz'

      expect(fs.exists '/foo/file.ext').toBeTruthy()
      expect(fs.exists '/foo/bar/file.ext').toBeTruthy()
      expect(fs.exists '/foo/baz/file.ext').toBeTruthy()

      expect(fs.read '/foo/file.ext').toBe('foo')
      expect(fs.read '/foo/bar/file.ext').toBe('bar')
      expect(fs.read '/foo/baz/file.ext').toBe('baz')

    it 'should allow to specify a root path that defines the structure
        base path'.squeeze(), ->

      fs = new FileSystem {}, '/foo/bar/'

      fs.mkdir '/foo/bar/baz'

      expect(fs.exists '/foo/bar/baz').toBeTruthy()
      expect(fs.browseTo '/foo/bar').toBe(fs.structure)





