Neat = require 'neat'
Neat.require 'core'
{findSync} = Neat.require "utils/files"

paths = Neat.paths.map (p) -> "#{p}/test/helpers"
files = findSync 'coffee', paths
files.forEach (f) -> require f
