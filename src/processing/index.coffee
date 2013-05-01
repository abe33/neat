Neat = require '../neat'
{combine} = Neat.require "utils/exports"

paths = Neat.paths.map (p) -> "#{p}/lib/processing"
module.exports = combine /\.build$/, paths
