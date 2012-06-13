{resolve} = require 'path'
{Neat} = require '../env'
{namespace} = require resolve Neat.neatRoot, "lib/utils/exports"
{describe} = require resolve Neat.neatRoot, "lib/utils/commands"

describe 'A sample generator',
sample = (generator, args..., cb) ->
  console.log generator
  console.log args
  cb?()

module.exports = namespace "sample",
  index:sample
  foo:sample
  bar:sample

