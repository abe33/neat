{resolve} = require 'path'
Neat = require '../neat'
{combine} = require "../utils/exports"

module.exports = combine /\.gen$/,
                         Neat.paths.map (p) -> "#{p}/lib/generators"
