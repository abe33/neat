{resolve} = require 'path'
Neat = require '../neat'
{combine} = require "../utils/exports"

module.exports = combine /\.cmd$/,
                         Neat.paths.map (p) -> "#{p}/lib/commands"
