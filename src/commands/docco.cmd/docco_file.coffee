{basename, extname, relative} = require 'path'
Neat = require '../../neat'

class DoccoFile
  constructor: (@path) ->
    @relativePath = relative Neat.root, @path
    @basename = basename @path
    outputBase = @relativePath.replace(extname(@path), '').underscore()
    @outputPath = "#{Neat.root}/docs/#{outputBase}.html"
    @linkPath = relative "#{Neat.root}/docs", @outputPath

module.exports = DoccoFile
