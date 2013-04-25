fs = require 'fs'
path = require 'path'
{print} = require 'util'
{resolve} = require 'path'
{exec} = require 'child_process'

Neat = require '../lib/neat'
Neat.require 'core'
{run} = Neat.require 'utils/commands'
{rmSync:rm, ensurePath, touch} = Neat.require 'utils/files'
{findSync} = Neat.require "utils/files"

global.TEST_ROOT = resolve '.'
global.TEST_TMP_DIR = '/tmp'
global.FIXTURES_ROOT = resolve Neat.neatRoot, 'test/fixtures'
global.NEAT_BIN = resolve __dirname, '../bin/neat'

global.subject = (name, block) ->
  [name, block] = [block, name] if typeof name is 'function'
  beforeEach ->
    @subject = block.call this
    @[name] = @subject if name?

global.given = (name, block) ->
  beforeEach ->
    self = this
    Object.defineProperty this, name,
                          configurable: true,
                          enumerable: true,
                          get: -> self["__#{name}"] ?= block.call self
  afterEach ->
    delete @[name]

global.waiting = (block) ->
  beforeEach ->
    ended = false
    runs -> block.call(this).then -> ended = true
    waitsFor progress(-> ended), 'Timed out during promise', 2000

global.waits = (scope, timeout, blockWait, block) ->
  start = new Date()
  f = ->
    return scope.fail(new Error 'Timed out') if new Date() - start > timeout

    if blockWait() then block() else setTimeout f, 0
  f()

cursor = 0
global.progress = (f) ->
  oldRes = false
  ->
    res = f.apply(this, arguments)
    p = Math.round(new Date().getMilliseconds() / 60) % 4
    setTimeout (-> print "\b" unless oldRes), 10
    print "#{'|/-\\'[p]}" unless res
    oldRes = res

global.fixture = (path) -> resolve FIXTURES_ROOT, path
global.loadFixture = (path) -> fs.readFileSync(fixture path).toString()
global.tmp = (path) -> resolve TEST_TMP_DIR, path
global.clearTmp = (path) -> rm resolve TEST_TMP_DIR, path

paths = Neat.paths.map (p) -> "#{p}/test/helpers"
files = findSync 'coffee', paths
files.forEach (f) -> require f
