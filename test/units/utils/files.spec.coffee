require '../../test_helper'
fs = require 'fs'
path = require 'path'
{resolve} = require "path"

root = resolve __dirname, '../../../'

existsSync = fs.existsSync or path.existsSync

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

  it 'should preserve the dots in dir names', ->
    expect(fu.noExtension "foo.bar/foo.js").toBe("foo.bar/foo")

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

describe 'findSiblingFileSync', ->
  it '''should find the corresponding file in a different directory
        and with a different extension''', ->
    start = "#{root}/foo/utils/files/file.coffee"
    roots = [root]

    expect(fu.findSiblingFileSync start, roots, "test/fixtures", "js")
      .toBe("#{root}/test/fixtures/utils/files/file.js")

    expect(fu.findSiblingFileSync start, roots, "test/fixtures", "coffee")
      .toBe("#{root}/test/fixtures/utils/files/file.coffee")

    expect(fu.findSiblingFileSync start, roots, "test/fixtures", "*")
      .toBe("#{root}/test/fixtures/utils/files/file.coffee")

    file_d = "#{root}/foo/utils/files/folder/file_d"

    expect(fu.findSiblingFileSync "#{file_d}.hamlc",
                                  roots, "test/fixtures", "*")
      .toBe("#{root}
            /test/fixtures/utils/files/folder/file_d/index.coffee".compact())

    expect(fu.findSiblingFileSync "#{file_d}.hamlc",
                                  roots, "test/fixtures", "coffee")
      .toBe("#{root}
            /test/fixtures/utils/files/folder/file_d/index.coffee".compact())

    expect(fu.findSiblingFileSync "#{file_d}.hamlc",
                                  roots, "test/fixtures", "js")
      .toBeUndefined()

  it 'should return void when there\'s no files that matches', ->
    roots = [root]
    expect(fu.findSiblingFileSync "#{root}/foo/commands.hamlc",
                                  roots, "test/fixtures", "coffee")
      .toBeUndefined()

    expect(fu.findSiblingFileSync "#{root}/foo/bar",
                                  roots, "test/fixtures", "*")
      .toBeUndefined()

  it 'should return void when start isn\'t in a neat project', ->
    roots = [root]
    expect(fu.findSiblingFileSync "/usr/bin/foo/commands.hamlc",
                                  roots, "test/fixtures", "coffee")
      .toBeUndefined()


  describe 'when an array is passed as last argument', ->
    it "should allow to retrieve the looked paths", ->
      roots = [root]
      a = []
      p = fu.findSiblingFileSync "#{root}/lib/commands.js",
                                 roots, "src", "*", a

      expect(a).toContain("#{root}/src/commands")
      expect(a).toContain("#{root}/src/commands/index")

      a = []
      p = fu.findSiblingFileSync "#{root}
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

describe 'findSiblingFile', ->
  start = "#{root}/foo/utils/files/file.coffee"
  roots = [root]

  it '''should find the corresponding file in a different directory
        and with js extension''', (done) ->

    fu.findSiblingFile start, roots, "test/fixtures", "js", (err, file) ->
      expect(err).toBeNull()
      expect(file).toBe("#{root}/test/fixtures/utils/files/file.js")
      done()

  it '''should find the corresponding file in a different directory
        and with coffee extension''', (done) ->

    fu.findSiblingFile start, roots, "test/fixtures", "coffee", (err, file) ->
      expect(err).toBeNull()
      expect(file).toBe("#{root}/test/fixtures/utils/files/file.coffee")
      done()

  it '''should find the corresponding file in a different directory
        and with any extension''', (done) ->

    fu.findSiblingFile start, roots, "test/fixtures", (err, file) ->
      expect(err).toBeNull()
      expect(file).toBe("#{root}/test/fixtures/utils/files/file.coffee")
      done()

  file_d = "#{root}/foo/utils/files/folder/file_d.hamlc"

  it 'should find the corresponding index file in a directory', (done) ->
    fu.findSiblingFile file_d, roots, "test/fixtures","*", (err, file) ->
      expect(err).toBeNull()
      expect(file).toBe("#{root}/test/fixtures/utils/files
                         /folder/file_d/index.coffee".compact())
      done()

  it '''should find the corresponding index file that match the extension
        in a directory''', (done) ->
    fu.findSiblingFile file_d, roots, "test/fixtures", "coffee", (err, file) ->
      expect(err).toBeNull()
      expect(file).toBe("#{root}/test/fixtures/utils/files
                         /folder/file_d/index.coffee".compact())
      done()

  it '''should not return the index when it doesn't
        match the extension''', (done) ->

    start = "#{file_d}.hamlc"
    fu.findSiblingFile start, roots, "test/fixtures", "js", (err, file) ->
      expect(err).toBeNull()
      expect(file).toBeUndefined()
      done()

  it '''should return void when there's no files that matches
        the extension''', (done) ->
    roots = [root]
    start = "#{root}/foo/commands.hamlc"
    fu.findSiblingFile start, roots, "test/fixtures", "coffee", (err, file) ->
      expect(err).toBeNull()
      expect(file).toBeUndefined()
      done()

  it '''should return void when there's no files that matches''', (done) ->
    roots = [root]
    start = "#{root}/foo/commands.hamlc"
    fu.findSiblingFile start, roots, "test/fixtures", "*", (err, file) ->
      expect(err).toBeNull()
      expect(file).toBeUndefined()
      done()

  it '''should return void when start isn't in a neat project''', (done) ->
    roots = [root]
    start = "/usr/bin/foo/commands.hamlc"
    fu.findSiblingFile start, roots, "test/fixtures", "coffee", (err, file) ->
      expect(err).toBeDefined()
      expect(file).toBeUndefined()
      done()

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

describe 'find', ->
  it '''should all the files with the passed-in extension
        in the given directory and sub directories''', (done) ->

    dir = "#{root}/test/fixtures/utils/files"
    fu.find "coffee", dir, (err, files) ->

      expect(err).toBeNull()
      expect(files).not.toBeUndefined()
      expect(files).toContain("#{dir}/file.coffee")
      expect(files).toContain("#{dir}/file_a.coffee")
      expect(files).toContain("#{dir}/folder/file_b.coffee")
      expect(files).toContain("#{dir}/folder/file_c.coffee")
      expect(files).toContain("#{dir}/folder/file_d/index.coffee")
      done()

  it '''should find all the files in the given dir that
        match the passed-in pattern''', (done) ->
    dir = "#{root}/test/fixtures/utils/files"
    fu.find /_[a-z]{1}$/, "coffee", dir, (err, files) ->

      expect(err).toBeNull()
      expect(files).not.toBeUndefined()
      expect(files).toContain("#{dir}/file_a.coffee")
      expect(files).toContain("#{dir}/folder/file_b.coffee")
      expect(files).toContain("#{dir}/folder/file_c.coffee")
      expect(files).toContain("#{dir}/folder/file_d/index.coffee")
      expect(files).not.toContain("#{dir}/file.coffee")
      done()

  it '''should find all the files with the passed-in extension
        in the given directories''', (done) ->

    dirs = [
      "#{root}/test/fixtures/utils/files/folder",
      "#{root}/test/fixtures/utils/files/folder2"
    ]
    fu.find "coffee", dirs, (err, files) ->

      expect(err).toBeNull()
      expect(files).not.toBeUndefined()
      expect(files).toContain("#{dirs[0]}/file_b.coffee")
      expect(files).toContain("#{dirs[0]}/file_c.coffee")
      expect(files).toContain("#{dirs[0]}/file_d/index.coffee")
      done()

  it '''should find all the files in the given dirs that
        match the passed-in pattern''', (done) ->
    dir = "#{root}/test/fixtures/utils/files"
    fu.find /_[a-z]{1}$/, "coffee", dir, (err, files) ->

      expect(err).toBeNull()
      expect(files).not.toBeUndefined()
      expect(files).toContain("#{dir}/folder/file_b.coffee")
      expect(files).toContain("#{dir}/folder/file_c.coffee")
      expect(files).toContain("#{dir}/folder/file_d/index.coffee")
      expect(files).not.toContain("#{dir}/file.coffee")
      done()

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

describe 'dirWithIndex', ->
  describe 'when the target folder contains an index', ->
    dir = "#{root}/test/fixtures/utils/files/folder/file_d"

    describe 'when no extension is passed to the function', ->
      it 'should return the path to the index', (done) ->
        fu.dirWithIndex dir, (f) ->
          expect(f).toBe("#{dir}/index.coffee")
          done()

    describe '''when an extension is passed to the function and
                the index have the same extension''', ->
      it 'should return the path to the index', (done) ->
        fu.dirWithIndex dir, "coffee", (f) ->
          expect(f).toBe("#{dir}/index.coffee")
          done()

    describe '''when an extension is passed to the function and
                the index don't have the same extension''', ->
      it 'should return null', (done) ->
        fu.dirWithIndex dir, "js", (f) ->
          expect(f).toBeUndefined()
          done()

  describe 'when the target folder don\'t have an index', ->
    dir = "#{root}/test/fixtures/utils/files/folder"

    describe 'when no extension is passed to the function', ->
      it 'should return null', (done) ->
        fu.dirWithIndex dir, (f) ->
          expect(f).toBeUndefined()
          done()

    describe '''when an extension is passed to the function and
                the index have the same extension''', ->
      it 'should return null', (done) ->
        fu.dirWithIndex dir, "coffee", (f) ->
          expect(f).toBeUndefined()
          done()

    describe '''when an extension is passed to the function and
                the index don't have the same extension''', ->
      it 'should return null', (done) ->
        fu.dirWithIndex dir, "js", (f) ->
          expect(f).toBeUndefined()
          done()

  describe 'when the target folder don\'t exist', ->
    dir = "#{root}/test/fixtures/utils/files/foo"

    describe 'when no extension is passed to the function', ->
      it 'should return null', (done) ->
        fu.dirWithIndex dir, (f) ->
          expect(f).toBeUndefined()
          done()

    describe '''when an extension is passed to the function and
                the index have the same extension''', ->
      it 'should return null', (done) ->
        fu.dirWithIndex dir, "coffee", (f) ->
          expect(f).toBeUndefined()
          done()

    describe '''when an extension is passed to the function and
                the index don't have the same extension''', ->
      it 'should return null', (done) ->
        fu.dirWithIndex dir, "js", (f) ->
          expect(f).toBeUndefined()
          done()

describe 'ensureSync', ->
  base = "#{root}/test/fixtures/utils/files/foo"
  deep = "#{base}/bar"

  afterEach ->
    fs.rmdirSync deep if existsSync deep
    fs.rmdirSync base if existsSync base

  describe 'when called with a valid path to the dir to create', ->
    it 'should create the directory', ->
      fu.ensureSync base
      expect(existsSync base).toBeTruthy()

    it 'should return true', ->
      res = fu.ensureSync base
      expect(res).toBeTruthy()

  describe 'when called with a valid path to the dir that exist', ->
    it 'should return false', ->
      fu.ensureSync base
      res = fu.ensureSync base
      expect(res).toBeFalsy()

  describe 'when called with a path that contains a dir that do not exist', ->
    it 'should raise an error', ->
      expect(-> fu.ensureSync deep).toThrow()

describe 'ensure', ->
  base = "#{root}/test/fixtures/utils/files/foo"
  deep = "#{base}/bar"

  afterEach ->
    fs.rmdirSync deep if existsSync deep
    fs.rmdirSync base if existsSync base

  describe 'when called with a valid path to the dir to create', ->

    it 'should create the directory', (done) ->
      fu.ensure base, (err, created) ->
        expect(existsSync base).toBeTruthy()
        expect(created).toBeTruthy()
        done()

  describe 'when called with a path that contains a dir that do not exist', ->
    it 'should raise an error', (done) ->
      fu.ensure deep, (err, created) ->
        expect(err).not.toBeNull()
        expect(created).toBeFalsy()
        done()

describe 'ensurePathSync', ->
  base = "#{root}/test/fixtures/utils/files/foo"
  deep = "#{base}/bar"

  afterEach ->
    fs.rmdirSync deep if existsSync deep
    fs.rmdirSync base if existsSync base

  describe 'when called with a valid path to the dir to create', ->
    it 'should create the directory', ->
      fu.ensurePathSync deep
      expect(existsSync deep).toBeTruthy()

describe 'ensurePath', ->
  base = "#{root}/test/fixtures/utils/files/foo"
  deep = "#{base}/bar"

  afterEach ->
    fs.rmdirSync deep if existsSync deep
    fs.rmdirSync base if existsSync base

  describe 'when called with a valid path to the dir to create', ->
    it 'should create the directory', (done) ->
      fu.ensurePath deep, (err, created) ->
        expect(existsSync deep).toBeTruthy()
        expect(err).toBeNull()
        expect(created).toBeTruthy()
        done()

describe 'touchSync', ->
  base = "#{root}/test/fixtures/utils/files/foo.js"
  deep = "#{root}/test/fixtures/utils/files/foo/bar.coffee"

  afterEach ->
    fs.unlinkSync deep if existsSync deep
    fs.unlinkSync base if existsSync base

  describe 'when called with a valid path to the file to create', ->
    it 'should create the directory', ->
      res = fu.touchSync base
      expect(existsSync base).toBeTruthy()

    it 'should create return true', ->
      res = fu.touchSync base
      expect(res).toBeTruthy()

  describe 'when called with a valid path to the file that exist', ->
    it 'should create return false', ->
      fu.touchSync base
      res = fu.touchSync base
      expect(res).toBeFalsy()


  describe 'when called with a path that contains a file that do not exist', ->
    it 'should raise an error', ->
      expect(-> fu.touchSync deep).toThrow()

describe 'touch', ->
  base = "#{root}/test/fixtures/utils/files/foo.js"
  deep = "#{root}/test/fixtures/utils/files/foo/bar.coffee"

  afterEach ->
    fs.unlinkSync deep if existsSync deep
    fs.unlinkSync base if existsSync base

  describe 'when called with a valid path to the file to create', ->

    it 'should create the directory', (done) ->
      fu.touch base, (err, created) ->
        expect(existsSync base).toBeTruthy()
        expect(created).toBeTruthy()
        done()

  describe 'when called with a path that contains a file that do not exist', ->
    it 'should raise an error', (done) ->
      fu.touch deep, (err, created) ->
        expect(err).not.toBeNull()
        expect(created).toBeFalsy()
        done()

describe 'rmSync', ->
  beforeEach ->
    fs.mkdirSync "#{root}/test/fixtures/utils/files/rm"
    fs.mkdirSync "#{root}/test/fixtures/utils/files/rm/foo"
    fs.mkdirSync "#{root}/test/fixtures/utils/files/rm/bar"
    fs.writeFileSync "#{root}/test/fixtures/utils/files/rm/foo/index", ""
    fs.writeFileSync "#{root}/test/fixtures/utils/files/rm/bar/index", ""

  it 'should remove all the files and directories recursively', ->
    fu.rmSync "#{root}/test/fixtures/utils/files/rm"

    expect(existsSync "#{root}/test/fixtures/utils/files/rm").toBeFalsy()

describe 'rm', ->
  beforeEach ->
    fs.mkdirSync "#{root}/test/fixtures/utils/files/rm"
    fs.mkdirSync "#{root}/test/fixtures/utils/files/rm/foo"
    fs.mkdirSync "#{root}/test/fixtures/utils/files/rm/bar"
    fs.writeFileSync "#{root}/test/fixtures/utils/files/rm/foo/index", ""
    fs.writeFileSync "#{root}/test/fixtures/utils/files/rm/bar/index", ""

  it 'should remove all the files and directories recursively', (done) ->
    fu.rm "#{root}/test/fixtures/utils/files/rm", (err) ->

      expect(existsSync "#{root}/test/fixtures/utils/files/rm").toBeFalsy()
      done()

describe 'readFiles', ->
  it 'should return a hash with the path and content of the files', (done) ->
    files = [
      "#{root}/test/fixtures/utils/files/readFiles/file1.txt"
      "#{root}/test/fixtures/utils/files/readFiles/file2.txt"
    ]
    expected = {}
    expected[files[0]] = "File 1 content\n"
    expected[files[1]] = "File 2 content\n"

    fu.readFiles files, (err, res) ->
      expect(String(content)).toEqual(expected[path]) for path, content of res
      done()

describe 'readFilesSync', ->
  it 'should return a hash with the path and content of the files', ->
    files = [
      "#{root}/test/fixtures/utils/files/readFiles/file1.txt"
      "#{root}/test/fixtures/utils/files/readFiles/file2.txt"
    ]
    expected = {}
    expected[files[0]] = "File 1 content\n"
    expected[files[1]] = "File 2 content\n"

    res = fu.readFilesSync files
    expect(String(content)).toEqual(expected[path]) for path, content of res
