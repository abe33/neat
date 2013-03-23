Neat = require '../neat'
{combine} = require "../utils/exports"

paths = Neat.paths.map (p) -> "#{p}/lib/watchers"
module.exports = combine /\.*/, paths
