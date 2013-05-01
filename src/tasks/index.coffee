{resolve} = require 'path'
Neat = require '../neat'
{combine} = require "../utils/exports"

module.exports = combine /\.cake$/,
                         Neat.paths.map (p) -> "#{p}/lib/tasks"
