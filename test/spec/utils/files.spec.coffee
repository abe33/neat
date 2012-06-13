{resolve} = require "path"

root = resolve __dirname, '../../../'

fu = require "#{root}/lib/utils/files"

describe 'noExtension', ->
  it 'should remove all the extensions from the path', ->
    expect(fu.noExtension "foo.bar.baz").toBe("foo")

  it 'should preserve the path and only remove extensions', ->
    expect(fu.noExtension "foo/bar.baz").toBe("foo/bar")

  it 'should preserve the path of an hidden file', ->
    expect(fu.noExtension "foo/.foo.baz").toBe("foo/.foo")

  it 'should preserve the path of an hidden file', ->
    expect(fu.noExtension "foo/.foo").toBe("foo/.foo")

  describe 'when there\'s no extension', ->
    it 'should leave the path unchanged', ->
      expect(fu.noExtension "/foo/bar/baz").toBe("/foo/bar/baz")

describe 'neatRootSync', ->
  describe 'when in a neat project folder', ->
    it 'should return the project path', ->
      expect(fu.neatRootSync __filename).toBe(root)

    it 'should return the project path even without argument', ->
      expect(fu.neatRootSync()).toBe(root)

  describe 'when not in a neat project folder', ->
    it 'should return null', ->
      expect(fu.neatRootSync resolve root, "..").toBeUndefined()


describe 'findSiblingFile', ->
  it '''should find the corresponding file in a different directory
        and with a different extension''', ->
    start = "#{root}/foo/utils/files/file.coffee"
    roots = [root]

    expect(fu.findSiblingFile start, roots, "test/fixtures", "js")
      .toBe("#{root}/test/fixtures/utils/files/file.js")

    expect(fu.findSiblingFile start, roots, "test/fixtures", "coffee")
      .toBe("#{root}/test/fixtures/utils/files/file.coffee")

    expect(fu.findSiblingFile start, roots, "test/fixtures", "*")
      .toBe("#{root}/test/fixtures/utils/files/file.coffee")

    file_d = "#{root}/foo/utils/files/folder/file_d"

    expect(fu.findSiblingFile "#{file_d}.hamlc", roots, "test/fixtures", "*")
      .toBe("#{root}
            /test/fixtures/utils/files/folder/file_d/index.coffee".compact())

    expect(fu.findSiblingFile "#{file_d}.hamlc",
                              roots,
                              "test/fixtures",
                              "coffee")
      .toBe("#{root}
            /test/fixtures/utils/files/folder/file_d/index.coffee".compact())

    expect(fu.findSiblingFile "#{file_d}.hamlc", roots, "test/fixtures", "js")
      .toBeUndefined()

  it 'should return void when there\'s no files that matches', ->
    roots = [root]
    expect(fu.findSiblingFile "#{root}/foo/commands.hamlc", roots,
           "test/fixtures", "coffee").toBeUndefined()

    expect(fu.findSiblingFile "#{root}/foo/bar",
                              roots, "test/fixtures", "*")
      .toBeUndefined()

  it 'should return void when start isn\'t in a neat project', ->
    roots = [root]
    expect(fu.findSiblingFile "/usr/bin/foo/commands.hamlc", roots,
           "test/fixtures", "coffee").toBeUndefined()


  describe 'when an array is passed as last argument', ->
    it "should allow to retrieve the looked paths", ->
      roots = [root]
      a = []
      p = fu.findSiblingFile "#{root}/lib/commands.js",
                             roots, "src", "*", a

      expect(a).toContain("#{root}/src/commands")
      expect(a).toContain("#{root}/src/commands/index")

      a = []
      p = fu.findSiblingFile "#{root}
                              /foo/utils/files/folder/file_d.js".compact(),
                             roots,
                             "test/fixtures",
                             "coffee",
                             a

      file_d = "#{root}/test/fixtures/utils/files/folder/file_d"
      expect(a)
        .toContain("#{file_d}.coffee")
      expect(a)
        .toContain("#{file_d}/index.coffee")


describe 'findSync', ->
  it '''should all the files with the passed-in extension
        in the given directory and sub directories''', ->

    dir = "#{root}/test/fixtures/utils/files"
    files = fu.findSync "coffee", dir

    expect(files).not.toBeUndefined()
    expect(files).toContain("#{dir}/file.coffee")
    expect(files).toContain("#{dir}/file_a.coffee")
    expect(files).toContain("#{dir}/folder/file_b.coffee")
    expect(files).toContain("#{dir}/folder/file_c.coffee")
    expect(files).toContain("#{dir}/folder/file_d/index.coffee")

  it '''should findSync all the files in the given dir that
        match the passed-in pattern''', ->
    dir = "#{root}/test/fixtures/utils/files"
    files = fu.findSync /_[a-z]{1}$/, "coffee", dir

    expect(files).not.toBeUndefined()
    expect(files).toContain("#{dir}/file_a.coffee")
    expect(files).toContain("#{dir}/folder/file_b.coffee")
    expect(files).toContain("#{dir}/folder/file_c.coffee")
    expect(files).toContain("#{dir}/folder/file_d/index.coffee")
    expect(files).not.toContain("#{dir}/folder/file.coffee")

describe 'dirWithIndexSync', ->
  describe 'when the target folder contains an index', ->
    dir = "#{root}/test/fixtures/utils/files/folder/file_d"

    describe 'when no extension is passed to the function', ->
      it 'should return the path to the index', ->
        f = fu.dirWithIndexSync dir

        expect(f).toBe("#{dir}/index.coffee")

    describe '''when an extension is passed to the function and
                the index have the same extension''', ->
      it 'should return the path to the index', ->
        f = fu.dirWithIndexSync dir, "coffee"

        expect(f).toBe("#{dir}/index.coffee")

    describe '''when an extension is passed to the function and
                the index don't have the same extension''', ->
      it 'should return null', ->
        f = fu.dirWithIndexSync dir, "js"

        expect(f).toBeUndefined()

  describe 'when the target folder don\'t have an index', ->
    dir = "#{root}/test/fixtures/utils/files/folder"

    describe 'when no extension is passed to the function', ->
      it 'should return null', ->
        f = fu.dirWithIndexSync dir

        expect(f).toBeUndefined()

    describe '''when an extension is passed to the function and
                the index have the same extension''', ->
      it 'should return null', ->
        f = fu.dirWithIndexSync dir, "coffee"

        expect(f).toBeUndefined()

    describe '''when an extension is passed to the function and
                the index don't have the same extension''', ->
      it 'should return null', ->
        f = fu.dirWithIndexSync dir, "js"

        expect(f).toBeUndefined()

  describe 'when the target folder don\'t exist', ->
    dir = "#{root}/test/fixtures/utils/files/foo"

    describe 'when no extension is passed to the function', ->
      it 'should return null', ->
        f = fu.dirWithIndexSync dir

        expect(f).toBeUndefined()

    describe '''when an extension is passed to the function and
                the index have the same extension''', ->
      it 'should return null', ->
        f = fu.dirWithIndexSync dir, "coffee"

        expect(f).toBeUndefined()

    describe '''when an extension is passed to the function and
                the index don't have the same extension''', ->
      it 'should return null', ->
        f = fu.dirWithIndexSync dir, "js"

        expect(f).toBeUndefined()
