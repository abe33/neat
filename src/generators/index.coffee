Neat = require '../neat'
{combine} = require "../utils/exports"

paths = Neat.paths.map (p) -> "#{p}/lib/generators"
module.exports = combine /\.gen$/, paths
